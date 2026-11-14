"""Download historical NASA POWER daily weather and aggregate crop seasons.

Input: data/locations.csv copied from data/templates/locations_template.csv.
Output: data/power_season_features.csv. Satellite features and target labels
must be joined from their own documented sources before model training.
"""
from pathlib import Path
import sys
import time
import requests
import pandas as pd

ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parent
INPUT = PROJECT / "data" / "locations.csv"
OUTPUT = PROJECT / "data" / "power_season_features.csv"
API = "https://power.larc.nasa.gov/api/temporal/daily/point"
PARAMS = "T2M,T2M_MAX,PRECTOTCORR,ALLSKY_SFC_SW_DWN"


def valid_number(value):
    try:
        number = float(value)
        return number if number > -90 else None
    except (TypeError, ValueError):
        return None


def season_dates(year, start_month, end_month):
    start = pd.Timestamp(year=int(year), month=int(start_month), day=1)
    end_year = int(year) + (1 if int(end_month) < int(start_month) else 0)
    end = pd.Timestamp(year=end_year, month=int(end_month), day=1) + pd.offsets.MonthEnd(0)
    return start, end


def main():
    if not INPUT.exists():
        raise FileNotFoundError(f"Copy data/templates/locations_template.csv to {INPUT.name} and edit it first.")
    locations = pd.read_csv(INPUT)
    required = ["location_id", "crop", "latitude", "longitude", "season_start_month", "season_end_month", "first_year", "last_year"]
    missing = [c for c in required if c not in locations.columns]
    if missing:
        raise ValueError(f"Missing columns in locations.csv: {missing}")
    output_rows = []
    for _, loc in locations.iterrows():
        first, last = int(loc.first_year), int(loc.last_year)
        request_start = pd.Timestamp(first, 1, 1)
        request_end = pd.Timestamp(last + 1, 12, 31) if int(loc.season_end_month) < int(loc.season_start_month) else pd.Timestamp(last, 12, 31)
        params = {
            "parameters": PARAMS, "community": "AG", "longitude": float(loc.longitude),
            "latitude": float(loc.latitude), "start": request_start.strftime("%Y%m%d"),
            "end": request_end.strftime("%Y%m%d"), "format": "JSON", "time-standard": "UTC"
        }
        print(f"NASA POWER: {loc.location_id} ({params['start']}–{params['end']})")
        response = requests.get(API, params=params, timeout=120)
        response.raise_for_status()
        payload = response.json().get("properties", {}).get("parameter", {})
        if not payload.get("T2M"):
            print(f"No data returned for {loc.location_id}; skipped", file=sys.stderr)
            continue
        daily = []
        for date_key, temp in payload["T2M"].items():
            daily.append({
                "date": pd.to_datetime(date_key, format="%Y%m%d"),
                "temp": valid_number(temp),
                "temp_max": valid_number(payload.get("T2M_MAX", {}).get(date_key)),
                "rain": valid_number(payload.get("PRECTOTCORR", {}).get(date_key)),
                "solar": valid_number(payload.get("ALLSKY_SFC_SW_DWN", {}).get(date_key)),
            })
        frame = pd.DataFrame(daily).dropna(subset=["temp"])
        for year in range(first, last + 1):
            start, end = season_dates(year, loc.season_start_month, loc.season_end_month)
            season = frame[(frame.date >= start) & (frame.date <= end)]
            if len(season) < 30:
                continue
            output_rows.append({
                "location_id": str(loc.location_id), "crop": str(loc.crop),
                "latitude": float(loc.latitude), "longitude": float(loc.longitude), "year": year,
                "temp_mean_c": season.temp.mean(), "temp_max_c": season.temp_max.max(),
                "rainfall_total_mm": season.rain.sum(min_count=1),
                "solar_mean_kwh_m2_day": season.solar.mean(),
                "season_start": start.date().isoformat(), "season_end": end.date().isoformat(),
                "weather_days": int(len(season)),
            })
        time.sleep(1.0)
    if not output_rows:
        raise RuntimeError("No season rows were produced. Check coordinates, dates and NASA POWER response.")
    pd.DataFrame(output_rows).to_csv(OUTPUT, index=False)
    print(f"Saved {len(output_rows)} season rows to {OUTPUT}")
    print("Next: join matching SMAP soil moisture, HLS/Landsat NDVI and observed stress/yield labels. This file alone is not a labelled training set.")

if __name__ == "__main__":
    main()
