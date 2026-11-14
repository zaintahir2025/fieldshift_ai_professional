import React, { useEffect, useMemo, useState } from "react";
import {
  Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis,
  BarChart, Bar, Legend
} from "recharts";
import {
  Activity, ArrowDownRight, ArrowUpRight, Bell, CalendarDays, Check,
  ChevronDown, Cloud, CloudRain, Droplets, ExternalLink, Globe2, Leaf,
  LocateFixed, MapPin, Menu, RefreshCw, Search, Settings2, ShieldAlert,
  Sprout, Sun, Thermometer, TrendingUp, Waves, X
} from "lucide-react";
import { MapContainer, TileLayer, CircleMarker, Popup, useMap, LayersControl } from "react-leaflet";

const PLACES = {
  "Faisalabad, Pakistan": { lat: 31.4504, lon: 73.1350, region: "Punjab, Pakistan" },
  "Multan, Pakistan": { lat: 30.1575, lon: 71.5249, region: "Punjab, Pakistan" },
  "Lahore, Pakistan": { lat: 31.5204, lon: 74.3587, region: "Punjab, Pakistan" },
  "Sahiwal, Pakistan": { lat: 30.6682, lon: 73.1114, region: "Punjab, Pakistan" },
  "Hyderabad, Pakistan": { lat: 25.3960, lon: 68.3578, region: "Sindh, Pakistan" },
  "Nairobi, Kenya": { lat: -1.2921, lon: 36.8219, region: "Kenya" },
  "Sacramento, USA": { lat: 38.5816, lon: -121.4944, region: "California, USA" },
  "São Paulo, Brazil": { lat: -23.5505, lon: -46.6333, region: "Brazil" }
};

const fmt = (v, digits=1) => Number.isFinite(Number(v)) ? Number(v).toFixed(digits) : "—";
const mean = (arr) => arr.length ? arr.reduce((a,b)=>a+b,0)/arr.length : 0;

function scoreFarm({temp, rain, solar}) {
  // Transparent prototype heuristic, not a validated agronomic model.
  const heat = Math.max(0, Math.min(100, (temp - 18) * 5));
  const dry = rain == null ? 0 : Math.max(0, Math.min(100, 65 - rain * 2.2));
  const score = Math.round(Math.max(0, Math.min(100, 100 - heat * .45 - dry * .55)));
  return { score, heat: Math.round(heat), drought: Math.round(dry), solar: Math.round(Math.max(0, Math.min(100, solar / 25))) };
}


function buildPredictiveOutlook(rows, cropName) {
  // Transparent trend extrapolation from recent NASA POWER observations.
  // This is an experimental risk indicator, NOT a meteorological forecast.
  const recent = rows.slice(-14);
  if (recent.length < 7) return null;
  const temps = recent.map(r => Number(r.temp)).filter(Number.isFinite);
  const rains = recent.map(r => Number(r.rain)).filter(Number.isFinite);
  if (temps.length < 7 || rains.length < 7) return null;

  const n = temps.length;
  const xMean = (n - 1) / 2;
  const yMean = temps.reduce((a,b)=>a+b,0) / n;
  let numerator = 0, denominator = 0;
  temps.forEach((v,i) => { numerator += (i-xMean)*(v-yMean); denominator += (i-xMean)**2; });
  const dailyTempSlope = denominator ? numerator / denominator : 0;
  const lastTemp = temps[temps.length-1];
  const projectedMeanTemp = lastTemp + dailyTempSlope * 4; // mean of projected days 1..7
  const recentRainTotal = rains.reduce((a,b)=>a+b,0);
  const projected7DayRain = (recentRainTotal / rains.length) * 7; // persistence baseline, not forecast
  const dryDays = rains.filter(v => v < 1).length;

  const heatThresholds = { Wheat: 30, Rice: 35, Cotton: 35, Maize: 32, Sugarcane: 35 };
  const heatThreshold = heatThresholds[cropName] || 32;
  const heatRisk = Math.max(0, Math.min(100, Math.round((projectedMeanTemp - (heatThreshold - 5)) * 10)));
  const dryRisk = Math.max(0, Math.min(100, Math.round((dryDays / rains.length) * 65 + Math.max(0, 14 - recentRainTotal) * 2.5)));
  const combined = Math.round(heatRisk * 0.55 + dryRisk * 0.45);
  const level = combined >= 70 ? "High" : combined >= 40 ? "Moderate" : "Lower";
  const confidence = recent.length >= 14 ? "Low · trend-only" : "Very low · limited history";
  return {
    projectedMeanTemp, projected7DayRain, recentRainTotal, dryDays,
    heatRisk, dryRisk, combined, level, confidence, observations: recent.length,
    direction: dailyTempSlope > 0.15 ? "Warming trend" : dailyTempSlope < -0.15 ? "Cooling trend" : "Temperature trend stable",
    dailyTempSlope
  };
}

function gibsDate(daysAgo = 4) {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() - daysAgo);
  return date.toISOString().slice(0, 10);
}

function MapRecenter({ center }) {
  const map = useMap();
  useEffect(() => { map.setView(center, 6); }, [center, map]);
  return null;
}

function Sidebar({ active, onNavigate, open, setOpen }) {
  const nav = [
    ["Overview", Activity], ["Farm Explorer", Globe2], ["Crop Rotation", Sprout],
    ["Risk Calendar", CalendarDays], ["Data Sources", Waves]
  ];
  return <>
    {open && <div className="scrim" onClick={()=>setOpen(false)} />}
    <aside className={`sidebar ${open ? "sidebar-open" : ""}`}>
      <div className="brand">
        <div className="brand-mark"><Leaf size={22}/></div>
        <div><b>FIELD<span>SHIFT</span></b><small>EARTH INTELLIGENCE</small></div>
        <button className="icon-btn mobile-close" onClick={()=>setOpen(false)}><X size={18}/></button>
      </div>
      <div className="workspace"><span className="live-dot"/> LIVE WORKSPACE <ChevronDown size={14}/></div>
      <div className="nav-label">WORKSPACE</div>
      {nav.map(([name, Icon])=><button key={name} onClick={()=>onNavigate(name)} className={`nav-item ${active===name?"active":""}`}><Icon size={18}/>{name}{name==="Risk Calendar"&&<span className="nav-count">3</span>}</button>)}
      <div className="sidebar-bottom">
        <div className="earth-card"><div className="earth-icon"><Globe2 size={20}/></div><b>Earth data, local decisions.</b><p>Satellite-informed planning for resilient farms.</p></div>
        <button className={`nav-item ${active==="Settings"?"active":""}`} onClick={()=>onNavigate("Settings")}><Settings2 size={18}/> Settings</button>
        <div className="profile"><div className="avatar">FS</div><div><b>Field Analyst</b><small>Independent workspace</small></div><ChevronDown size={15}/></div>
      </div>
    </aside>
  </>;
}

function StatCard({icon:Icon, label, value, unit, trend, tone="green"}) {
  return <div className="stat-card">
    <div className={`stat-icon ${tone}`}><Icon size={19}/></div>
    <div className="stat-label">{label}</div>
    <div className="stat-value">{value}<small>{unit}</small></div>
    <div className="stat-foot"><span className="trend"><ArrowUpRight size={13}/>{trend}</span><span>NASA POWER · daily</span></div>
  </div>;
}

export default function App() {
  const [active, setActive] = useState("Overview");
  const [menuOpen, setMenuOpen] = useState(false);
  const [place, setPlace] = useState("Faisalabad, Pakistan");
  const [customPlace, setCustomPlace] = useState("");
  const [coords, setCoords] = useState(PLACES["Faisalabad, Pakistan"]);
  const [countries, setCountries] = useState([{ name: "Pakistan", code: "PK" }]);
  const [selectedCountry, setSelectedCountry] = useState("Pakistan");
  const [cityQuery, setCityQuery] = useState("Faisalabad");
  const [cityResults, setCityResults] = useState([]);
  const [cityBusy, setCityBusy] = useState(false);
  const [locationMessage, setLocationMessage] = useState("");
  const [weather, setWeather] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [range, setRange] = useState("30");
  const [crop, setCrop] = useState("Wheat");
  const [soil, setSoil] = useState("Loam");
  const [priority, setPriority] = useState("Water conservation");
  const [lastUpdated, setLastUpdated] = useState("");
  const [soilMoisture, setSoilMoisture] = useState("");
  const [ndviMean, setNdviMean] = useState("");
  const [ndviChange, setNdviChange] = useState("");
  const [apiStatus, setApiStatus] = useState("checking");
  const [assessmentBusy, setAssessmentBusy] = useState(false);
  const [assessmentResult, setAssessmentResult] = useState(null);
  const [assessmentMessage, setAssessmentMessage] = useState("");
  const [nasaObs, setNasaObs] = useState(null);
  const [nasaObsBusy, setNasaObsBusy] = useState(false);
  const [nasaObsError, setNasaObsError] = useState("");
  const apiBase = (import.meta.env.VITE_API_BASE_URL || "http://127.0.0.1:8000").replace(/\/$/, "");

  async function loadWeather(target=coords, days=30) {
    setLoading(true); setError("");
    try {
      const end = new Date(); end.setDate(end.getDate()-2);
      const start = new Date(end); start.setDate(start.getDate()-Number(days)+1);
      const date = d => d.toISOString().slice(0,10).replaceAll("-","");
      const url = `https://power.larc.nasa.gov/api/temporal/daily/point?parameters=T2M,T2M_MAX,PRECTOTCORR,ALLSKY_SFC_SW_DWN&community=AG&longitude=${target.lon}&latitude=${target.lat}&start=${date(start)}&end=${date(end)}&format=JSON`;
      const res = await fetch(url);
      if (!res.ok) throw new Error(`NASA POWER returned HTTP ${res.status}`);
      const json = await res.json();
      const p = json?.properties?.parameter || {};
      const keys = Object.keys(p.T2M || {}).filter(k => Number.isFinite(p.T2M[k]) && p.T2M[k] > -90);
      if (!keys.length) throw new Error("No valid daily observations were returned for this location/date range.");
      const numericOrNull = value => Number.isFinite(Number(value)) && Number(value) > -90 ? Number(value) : null;
      const rows = keys.map(k => ({
        date: `${k.slice(4,6)}/${k.slice(6,8)}`,
        temp: numericOrNull(p.T2M[k]),
        tempMax: numericOrNull(p.T2M_MAX?.[k]) ?? numericOrNull(p.T2M[k]),
        rain: numericOrNull(p.PRECTOTCORR?.[k]),
        solar: numericOrNull(p.ALLSKY_SFC_SW_DWN?.[k])
      }));
      const valid = field => rows.map(x=>x[field]).filter(Number.isFinite);
      const validRain = valid("rain");
      const validTemp = valid("temp");
      const validTempMax = valid("tempMax");
      const validSolar = valid("solar");
      if (!validTemp.length || !validTempMax.length) throw new Error("NASA POWER returned incomplete temperature observations for this period.");
      setWeather({
        rows,
        temp: mean(validTemp),
        tempMax: Math.max(...validTempMax),
        rain: validRain.length ? mean(validRain) : null,
        solar: validSolar.length ? mean(validSolar) : null,
        totalRain: validRain.length ? validRain.reduce((a,b)=>a+b,0) : null,
        count: rows.length,
        validRainDays: validRain.length,
        validTemperatureDays: validTemp.length
      });
      setLastUpdated(new Date().toLocaleString());
    } catch(e) {
      setError(`${e.message}. Check your internet connection and try again.`);
      setWeather(null);
    } finally { setLoading(false); }
  }

  useEffect(()=>{ loadWeather(coords, range); }, [coords, range]);

  // Global country directory. City search uses Open-Meteo's public geocoding API.
  useEffect(() => {
    let alive = true;
    fetch("https://restcountries.com/v3.1/all?fields=name,cca2")
      .then(r => { if (!r.ok) throw new Error("Country directory unavailable"); return r.json(); })
      .then(rows => {
        if (!alive) return;
        const list = rows.map(x => ({ name: x.name?.common, code: x.cca2 }))
          .filter(x => x.name && x.code).sort((a,b) => a.name.localeCompare(b.name));
        if (list.length) setCountries(list);
      })
      .catch(() => setLocationMessage("Country directory could not load. Check your internet connection."));
    return () => { alive = false; };
  }, []);

  async function searchCities(query = cityQuery, countryName = selectedCountry) {
    const term = query.trim();
    if (term.length < 2) { setLocationMessage("Enter at least 2 letters to search for a city."); return; }
    setCityBusy(true); setLocationMessage(""); setCityResults([]);
    try {
      const countryCode = countries.find(c => c.name === countryName)?.code;
      const params = new URLSearchParams({ name: term, count: "20", language: "en", format: "json" });
      if (countryCode) params.set("countryCode", countryCode);
      const response = await fetch(`https://geocoding-api.open-meteo.com/v1/search?${params}`);
      if (!response.ok) throw new Error(`City search failed (HTTP ${response.status})`);
      const data = await response.json();
      const results = (data.results || []).filter(x => Number.isFinite(x.latitude) && Number.isFinite(x.longitude));
      setCityResults(results);
      if (!results.length) setLocationMessage("No matching cities found. Try another spelling or choose a different country.");
    } catch (e) { setLocationMessage(`${e.message}. You can still enter coordinates manually.`); }
    finally { setCityBusy(false); }
  }

  function selectCity(city) {
    if (Math.abs(city.latitude) > 84.66) {
      setLocationMessage("This location is outside the supported NASA POWER latitude range (−84.66° to 84.66°).");
      return;
    }
    const countryName = city.country || selectedCountry;
    const label = [city.name, countryName].filter(Boolean).join(", ");
    setPlace(label);
    setSelectedCountry(countryName);
    setCityQuery(city.name);
    setCoords({ lat: city.latitude, lon: city.longitude, region: [city.admin1, countryName].filter(Boolean).join(", ") });
    setCityResults([]); setLocationMessage("");
  }

  function useMyLocation() {
    if (!navigator.geolocation) { setLocationMessage("Your browser does not support location access."); return; }
    setLocationMessage("Waiting for location permission…");
    navigator.geolocation.getCurrentPosition(pos => {
      const lat = pos.coords.latitude, lon = pos.coords.longitude;
      if (Math.abs(lat) > 84.66) { setLocationMessage("Your location is outside NASA POWER's supported latitude range."); return; }
      setCoords({ lat, lon, region: "GPS coordinates" });
      setPlace("My current location"); setLocationMessage("Location selected. Loading NASA POWER observations…");
    }, err => setLocationMessage(err.code === 1 ? "Location permission was denied. You can search for a city instead." : "Could not determine your location. Try city search."), { enableHighAccuracy: false, timeout: 10000, maximumAge: 300000 });
  }

  function exportWeatherCSV() {
    if (!weather?.rows?.length) { setError("Load NASA weather observations before exporting."); return; }
    const header = "date,temp_c,temp_max_c,rain_mm,solar_kwh_m2_day";
    const lines = weather.rows.map(r => [r.date, r.temp, r.tempMax, r.rain, r.solar].join(","));
    const blob = new Blob([[header, ...lines].join("\n")], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob); const a = document.createElement("a");
    a.href = url; a.download = "fieldshift_nasa_power_observations.csv"; a.click(); URL.revokeObjectURL(url);
  }

  useEffect(() => {
    fetch(`${apiBase}/health`)
      .then(r => { if (!r.ok) throw new Error("Backend unavailable"); return r.json(); })
      .then(() => setApiStatus("online"))
      .catch(() => setApiStatus("offline"));
  }, []);

  function assessCropConditions() {
    if (!weather) { setAssessmentMessage("Load NASA POWER weather observations first."); return; }
    setAssessmentBusy(true); setAssessmentMessage(""); setAssessmentResult(null);
    try {
      // Transparent screening heuristic, not a trained ML model or yield forecast.
      const nasaRootMoisture = nasaObs?.summary?.smap_rootzone_soil_moisture_m3_m3;
      const moisture = soilMoisture !== "" ? Number(soilMoisture) : (Number.isFinite(nasaRootMoisture) ? Number(nasaRootMoisture) : null);
      const moistureSource = soilMoisture !== "" ? "manually entered farm measurement" : (moisture !== null ? "NASA POWER HY / SMAP L4 root-zone estimate" : null);
      const ndvi = ndviMean === "" ? null : Number(ndviMean);
      const ndviDelta = ndviChange === "" ? null : Number(ndviChange);
      if (soilMoisture !== "" && (!Number.isFinite(moisture) || moisture < 0 || moisture > 1)) throw new Error("Soil moisture must be between 0 and 1 m³/m³.");
      if (ndvi !== null && (!Number.isFinite(ndvi) || ndvi < -1 || ndvi > 1)) throw new Error("NDVI mean must be between −1 and 1.");
      if (ndviDelta !== null && (!Number.isFinite(ndviDelta) || ndviDelta < -2 || ndviDelta > 2)) throw new Error("NDVI change must be between −2 and 2.");
      const cropHeat = { wheat: 30, rice: 35, cotton: 35, maize: 32, sugarcane: 35, chickpea: 30, "mung bean": 32 };
      const threshold = cropHeat[String(crop).toLowerCase()] ?? 32;
      let stress = 0; const reasons = [];
      if (weather.tempMax >= threshold) { stress += 35; reasons.push("Maximum temperature is at/above the selected crop screening threshold"); }
      else if (weather.tempMax >= threshold - 4) { stress += 18; reasons.push("Maximum temperature is approaching the selected crop screening threshold"); }
      if (weather.totalRain !== null && weather.totalRain < 10) { stress += 25; reasons.push("Low rainfall during the selected observation window"); }
      else if (weather.totalRain !== null && weather.totalRain < 30) { stress += 12; reasons.push("Limited rainfall during the selected observation window"); }
      if (moisture !== null && moisture < 0.15) { stress += 25; reasons.push("Entered soil-moisture value is low"); }
      else if (moisture !== null && moisture < 0.25) { stress += 12; reasons.push("Entered soil-moisture value is relatively low"); }
      if (ndvi !== null && ndvi < 0.3) { stress += 15; reasons.push("Entered NDVI is low"); }
      if (ndviDelta !== null && ndviDelta < -0.1) { stress += 10; reasons.push("Entered NDVI change indicates a decline"); }
      stress = Math.min(100, stress);
      const level = stress >= 60 ? "High stress" : stress >= 30 ? "Moderate stress" : "Low stress";
      const suitability = Math.max(0, 100 - stress);
      setAssessmentResult({
        stress: { prediction: level, score: stress, reasons: reasons.length ? reasons : ["No strong stress signals detected in the supplied inputs"], method: "Transparent rule-based screening", moisture_source: moistureSource, ndvi_source: ndvi === null ? null : "manually entered measurement" },
        yield: { suitability_index: suitability, category: suitability >= 70 ? "More suitable conditions" : suitability >= 45 ? "Mixed / monitor conditions" : "Less suitable conditions", warning: "This is a climate-and-input suitability index, not a yield estimate or tonnes/hectare prediction." }
      });
    } catch (e) { setAssessmentMessage(e.message || "Could not calculate screening result."); }
    finally { setAssessmentBusy(false); }
  }
  async function loadNasaObservations() {
    setNasaObsBusy(true); setNasaObsError(""); setNasaObs(null);
    try {
      const url = `${apiBase}/nasa/observations?latitude=${coords.lat}&longitude=${coords.lon}&days=30`;
      const response = await fetch(url);
      const data = await response.json();
      if (!response.ok) throw new Error(data.detail || `NASA data request failed (${response.status})`);
      setNasaObs(data);
    } catch (e) { setNasaObsError(e.message); }
    finally { setNasaObsBusy(false); }
  }
  const risk = useMemo(()=>weather ? scoreFarm(weather) : null,[weather]);
  const outlook = useMemo(()=>weather ? buildPredictiveOutlook(weather.rows, crop) : null,[weather, crop]);
  const rotation = useMemo(()=>{
    // Explicit demonstration rubric: scores respond to the selected crop, soil,
    // recent NASA POWER rainfall/heat and the farmer's stated priority.
    const candidates = [
      {name:"Chickpea", season:"Rabi · legume break crop", water:"Low", soilNote:"Legume; can contribute biological nitrogen", base:78, waterNeed:1, soilFit:{Loam:8,Sandy:2,Clay:1}, bestAfter:["Wheat","Maize","Cotton"]},
      {name:"Mung bean", season:"Kharif · short-duration legume", water:"Low–medium", soilNote:"Legume break crop; short duration", base:76, waterNeed:2, soilFit:{Loam:7,Sandy:3,Clay:1}, bestAfter:["Wheat","Rice","Cotton"]},
      {name:"Mustard", season:"Rabi · oilseed option", water:"Low", soilNote:"Adds crop diversity; check local disease/market fit", base:73, waterNeed:1, soilFit:{Loam:7,Sandy:2,Clay:3}, bestAfter:["Rice","Cotton","Maize"]},
      {name:"Maize", season:"Season depends on local calendar", water:"Medium", soilNote:"Cereal rotation option; avoid repeated cereal cycles", base:68, waterNeed:3, soilFit:{Loam:8,Sandy:2,Clay:2}, bestAfter:["Chickpea","Mung bean","Mustard"]}
    ];
    const rainfall = weather?.totalRain ?? null;
    const hot = weather?.tempMax ?? null;
    const rootMoisture = nasaObs?.summary?.smap_rootzone_soil_moisture_m3_m3;
    return candidates.map(item=>{
      let score=item.base; const reasons=[];
      if(item.bestAfter.includes(crop)){score+=8;reasons.push(`rotation sequence considered after ${crop}`);}
      if(priority==="Water conservation"){score += item.waterNeed===1?8:item.waterNeed===2?4:-5; reasons.push("water-demand preference");}
      if(priority==="Soil health" && ["Chickpea","Mung bean"].includes(item.name)){score+=9;reasons.push("legume / soil-health preference");}
      if(priority==="Crop diversification" && item.name!==crop){score+=5;reasons.push("diversification preference");}
      score += item.soilFit[soil] ?? 0; reasons.push(`${soil.toLowerCase()} soil screening fit`);
      if(rainfall!==null && rainfall<20 && item.waterNeed===1){score+=5;reasons.push("low recent rainfall favours lower-water option");}
      if(rainfall!==null && rainfall<20 && item.waterNeed===3){score-=6;reasons.push("low recent rainfall penalty");}
      if(rootMoisture!==null && rootMoisture!==undefined && rootMoisture<0.18 && item.waterNeed===3){score-=5;reasons.push("low NASA root-zone moisture proxy");}
      if(hot!==null && hot>38 && item.waterNeed===3){score-=3;reasons.push("recent heat exposure penalty");}
      score=Math.max(0,Math.min(100,score));
      return {...item,soil:item.soilNote,fit:score,reasons};
    }).sort((a,b)=>b.fit-a.fit).slice(0,3);
  },[soil,priority,crop,weather,nasaObs]);

  function choosePlace(v) {
    if (PLACES[v]) { setPlace(v); setCoords(PLACES[v]); }
  }
  function useCustom() {
    const parts = customPlace.split(",").map(Number);
    if (parts.length===2 && parts.every(Number.isFinite) && Math.abs(parts[0])<=90 && Math.abs(parts[1])<=180) {
      setPlace("Custom coordinates"); setCoords({lat:parts[0],lon:parts[1],region:"Custom location"});
    } else setError("Enter coordinates as latitude, longitude (for example 31.45, 73.13).");
  }

  const center = [coords.lat, coords.lon];
  const navTitle = active==="Overview" ? "Farm intelligence overview" : active;
  function navigateTo(section) {
    setActive(section);
    setMenuOpen(false);
    const target = document.getElementById(({"Overview":"overview","Farm Explorer":"farm-explorer","Crop Rotation":"crop-rotation","Risk Calendar":"risk-calendar","Data Sources":"data-sources","Settings":"settings"})[section]);
    if (target) target.scrollIntoView({behavior:"smooth",block:"start"});
  }
  return <div className="app-shell">
    <Sidebar active={active} onNavigate={navigateTo} open={menuOpen} setOpen={setMenuOpen}/>
    <main className="main">
      <header className="topbar">
        <button className="icon-btn mobile-menu" onClick={()=>setMenuOpen(true)}><Menu/></button>
        <div className="breadcrumb">Workspace <span>/</span> <b>{active}</b></div>
        <div className="top-actions"><span className="status-pill"><i/> {weather ? "NASA POWER data loaded" : loading ? "Loading NASA POWER" : "NASA POWER awaiting data"}</span><button className="icon-btn"><Bell size={18}/></button><div className="avatar">FS</div></div>
      </header>
      <div className="content" id="overview">
        <section className="page-heading">
          <div><div className="eyebrow"><span/> FIELD INTELLIGENCE PLATFORM</div><h1>{navTitle}<span>.</span></h1><p>Understand changing field conditions. Compare resilient crop choices.</p></div>
          <div className="heading-actions"><button className="secondary-btn" onClick={()=>loadWeather(coords,range)} disabled={loading}><RefreshCw size={15} className={loading?"spin":""}/>{loading?"Updating":"Refresh data"}</button><button className="primary-btn" onClick={()=>navigateTo("Crop Rotation")}><Sprout size={16}/> Explore rotations</button></div>
        </section>

        <section className="location-bar">
          <div className="location-symbol"><MapPin size={18}/></div>
          <div className="location-meta"><small>SELECTED FARM REGION</small><b>{place}</b><span>{coords.region} · {coords.lat.toFixed(3)}, {coords.lon.toFixed(3)}</span></div>
          <div className="location-controls global-location-controls">
            <select value={selectedCountry} onChange={e=>{setSelectedCountry(e.target.value);setCityResults([]);setLocationMessage("");}} aria-label="Select country">
              {countries.map(c=><option key={c.code} value={c.name}>{c.name}</option>)}
            </select>
            <input value={cityQuery} onChange={e=>setCityQuery(e.target.value)} onKeyDown={e=>{if(e.key==="Enter")searchCities();}} placeholder="Search city worldwide" aria-label="Search city"/>
            <button className="small-action" onClick={()=>searchCities()} disabled={cityBusy}><Search size={15}/>{cityBusy?"Searching":"Find city"}</button>
            <button className="small-action" onClick={useMyLocation}><LocateFixed size={15}/> My location</button>
            <input value={customPlace} onChange={e=>setCustomPlace(e.target.value)} placeholder="Latitude, longitude" aria-label="Custom latitude and longitude"/>
            <button className="small-action" onClick={useCustom}>Set coordinates</button>
          </div>
          {cityResults.length>0 && <div className="city-results" role="listbox" aria-label="City search results">{cityResults.map((city,i)=><button key={`${city.id||i}-${city.latitude}`} onClick={()=>selectCity(city)}><b>{city.name}</b><span>{[city.admin1,city.country].filter(Boolean).join(", ")} · {city.latitude.toFixed(3)}, {city.longitude.toFixed(3)}</span></button>)}</div>}
          {locationMessage && <div className="location-message">{locationMessage}</div>}
        </section>

        {error && <div className="error-banner"><ShieldAlert size={17}/><span>{error}</span><button onClick={()=>setError("")}><X size={16}/></button></div>}
        <section className="stats-grid">
          <StatCard icon={Thermometer} label="Mean air temperature" value={weather?fmt(weather.temp):"—"} unit="°C" trend="Daily average" tone="orange"/>
          <StatCard icon={CloudRain} label="Mean daily precipitation" value={weather?fmt(weather.rain,2):"—"} unit="mm/day" trend="Corrected rainfall" tone="blue"/>
          <StatCard icon={Sun} label="Solar radiation" value={weather?fmt(weather.solar):"—"} unit="kWh/m²/day" trend="Surface shortwave" tone="yellow"/>
          <div className="stat-card health-card"><div className="health-top"><div className="stat-icon green"><Activity size={19}/></div><span className="prototype-tag">INDICATIVE</span></div><div className="stat-label">Climate suitability index</div><div className="health-score">{risk?risk.score:"—"}<small>/100</small></div><div className="meter"><span style={{width:`${risk?.score||0}%`}}/></div><div className="stat-foot"><span>Heuristic prototype score</span><span>{risk?risk.score>=70?"Favorable":risk.score>=45?"Watch":"High stress":"Awaiting data"}</span></div></div>
        </section>

        <section className="dashboard-grid" id="farm-explorer">
          <div className="panel climate-panel">
            <div className="panel-header"><div><div className="panel-kicker">EARTH OBSERVATION · TIME SERIES</div><h2>Climate signals</h2><p>Daily temperature and precipitation at selected coordinates</p></div><select className="range-select" value={range} onChange={e=>setRange(e.target.value)}><option value="7">Last 7 days</option><option value="30">Last 30 days</option><option value="90">Last 90 days</option><option value="180">Last 180 days</option></select></div>
            <div className="chart-legend"><span><i className="legend-temp"/> Temperature (°C)</span><span><i className="legend-rain"/> Precipitation (mm/day)</span></div>
            <div className="chart-wrap">
              {loading && !weather ? <div className="chart-empty"><RefreshCw className="spin"/> Loading NASA POWER observations…</div> :
              weather ? <ResponsiveContainer width="100%" height="100%"><AreaChart data={weather.rows}><defs><linearGradient id="tempFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#d68a4a" stopOpacity={.22}/><stop offset="100%" stopColor="#d68a4a" stopOpacity={0}/></linearGradient></defs><CartesianGrid strokeDasharray="3 5" vertical={false} stroke="#e8ece8"/><XAxis dataKey="date" tick={{fontSize:11,fill:"#849087"}} tickLine={false} axisLine={false} minTickGap={24}/><YAxis yAxisId="left" tick={{fontSize:11,fill:"#849087"}} tickLine={false} axisLine={false}/><YAxis yAxisId="right" orientation="right" tick={{fontSize:11,fill:"#849087"}} tickLine={false} axisLine={false}/><Tooltip contentStyle={{border:"1px solid #e4e9e4",borderRadius:12,fontSize:12}}/><Area yAxisId="left" type="monotone" dataKey="temp" name="Temperature °C" stroke="#c77b3c" strokeWidth={2.2} fill="url(#tempFill)" dot={false}/><Area yAxisId="right" type="monotone" dataKey="rain" name="Precipitation mm" stroke="#4c91a5" strokeWidth={1.8} fill="#4c91a5" fillOpacity={.08} dot={false}/></AreaChart></ResponsiveContainer> :
              <div className="chart-empty">No observations yet. Refresh to retry.</div>}
            </div>
            <div className="chart-foot"><span><i className="live-dot"/> {weather?`${weather.count} daily records received`:"Waiting for data"}</span><span>Source: NASA POWER Daily API <a href="https://power.larc.nasa.gov/" target="_blank" rel="noreferrer"><ExternalLink size={12}/></a></span>{weather && <button className="small-action" onClick={exportWeatherCSV}>Export CSV</button>}</div>
          </div>
          <div className="panel map-panel">
            <div className="panel-header"><div><div className="panel-kicker">GEOSPATIAL CONTEXT</div><h2>Farm explorer</h2><p>Selected location and surrounding landscape</p></div><button className="icon-btn"><Globe2 size={17}/></button></div>
            <div className="map-frame"><MapContainer center={center} zoom={6} scrollWheelZoom={true} zoomControl={true}>
              <MapRecenter center={center}/>
              <LayersControl position="topright">
                <LayersControl.BaseLayer checked name="OpenStreetMap">
                  <TileLayer attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>' url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"/>
                </LayersControl.BaseLayer>
                <LayersControl.BaseLayer name="NASA MODIS true color">
                  <TileLayer attribution='NASA GIBS' url={`https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/MODIS_Terra_CorrectedReflectance_TrueColor/default/${gibsDate(4)}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.jpg`}/>
                </LayersControl.BaseLayer>
                <LayersControl.Overlay name="NASA SMAP / Sentinel-1 soil-moisture visualization">
                  <TileLayer opacity={0.65} attribution='NASA GIBS' url={`https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/SMAP_Sentinel-1_L2_Active_Passive_Soil_Moisture/default/${gibsDate(4)}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.png`}/>
                </LayersControl.Overlay>
                <LayersControl.Overlay name="NASA MODIS NDVI (8-day)">
                  <TileLayer opacity={0.7} attribution='NASA GIBS' url={`https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/MODIS_Terra_NDVI_8Day/default/${gibsDate(8)}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.png`}/>
                </LayersControl.Overlay>
                <LayersControl.Overlay name="NASA MODIS daytime land-surface temperature">
                  <TileLayer opacity={0.6} attribution='NASA GIBS' url={`https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/MODIS_Terra_Land_Surface_Temp_Day/default/${gibsDate(4)}/GoogleMapsCompatible_Level9/{z}/{y}/{x}.png`}/>
                </LayersControl.Overlay>
              </LayersControl>
              <CircleMarker center={center} radius={10} pathOptions={{color:"#236d4b",fillColor:"#5caa7d",fillOpacity:.85,weight:3}}><Popup><b>{place}</b><br/>NASA POWER point location</Popup></CircleMarker>
            </MapContainer></div>
            <div className="map-caption"><span><MapPin size={14}/>{place}</span><span>OpenStreetMap basemap</span></div>
          </div>
        </section>

        <section className="bottom-grid" id="crop-rotation">
          <div className="panel rotation-panel">
            <div className="panel-header"><div><div className="panel-kicker">DECISION SUPPORT · PROTOTYPE</div><h2>Rotation recommendations</h2><p>Explore possible break crops after your current crop</p></div><span className="ai-chip"><Activity size={13}/> FIELD SHIFT LOGIC</span></div>
            <div className="filters">
              <label>Current crop<select value={crop} onChange={e=>setCrop(e.target.value)}><option>Wheat</option><option>Rice</option><option>Cotton</option><option>Maize</option><option>Sugarcane</option></select></label>
              <label>Soil texture<select value={soil} onChange={e=>setSoil(e.target.value)}><option>Loam</option><option>Sandy</option><option>Clay</option></select></label>
              <label>Farm priority<select value={priority} onChange={e=>setPriority(e.target.value)}><option>Water conservation</option><option>Soil health</option><option>Crop diversification</option></select></label>
            </div>
            <div className="recommend-list">{rotation.map((r,i)=><div className="recommend-row" key={r.name}><div className="crop-rank">0{i+1}</div><div className="crop-details"><b>{r.name}</b><span>{r.season} · {r.soil}</span><small style={{display:"block",marginTop:3,color:"#7b887e"}}>{r.reasons.slice(0,2).join(" · ")}</small></div><div className="water-label"><Droplets size={13}/>{r.water} water</div><div className="fit"><b>{r.fit}</b><small>rule score</small></div></div>)}</div>
            <div className="disclaimer">Dynamic demonstration score (0–100), not a probability or validated yield forecast. It responds to current crop, soil texture, farmer priority, recent NASA POWER rainfall/heat and NASA root-zone moisture when fetched. Confirm season, market, irrigation and local agronomy before decisions.</div>
          </div>
          <div className="panel risk-panel" id="risk-calendar">
            <div className="panel-header"><div><div className="panel-kicker">SEASONAL OUTLOOK</div><h2>Risk watch</h2><p>Signals inferred from recent weather</p></div><ShieldAlert size={19} color="#c58a48"/></div>
            <div className="risk-item"><div className="risk-icon amber"><Thermometer size={17}/></div><div><b>Heat exposure</b><small>Temperature-based indicator</small></div><strong>{risk?risk.heat+"/100":"—"}</strong></div>
            <div className="risk-item"><div className="risk-icon blue"><Droplets size={17}/></div><div><b>Rainfall deficit</b><small>Rainfall proxy, not soil moisture</small></div><strong>{risk?risk.drought+"/100":"—"}</strong></div>
            <div className="risk-item"><div className="risk-icon green"><Sun size={17}/></div><div><b>Solar availability</b><small>Surface solar radiation proxy</small></div><strong>{risk?risk.solar+"/100":"—"}</strong></div>
            <div className="risk-note"><Cloud size={15}/> This is a retrospective weather summary, not a forecast or a measured crop-stress alert.</div>
          </div>
        </section>

        <section className="panel" id="data-sources" style={{padding:"18px 20px",marginBottom:15}}>
          <div className="panel-kicker">NASA SATELLITE LAYERS · MAP VISUALIZATION</div>
          <h2 style={{fontSize:17,margin:"7px 0"}}>Earth observation context</h2>
          <p style={{fontSize:11,color:"#849087",lineHeight:1.7,margin:0}}>Use the map layer selector to switch NASA MODIS true-colour imagery and toggle SMAP/Sentinel-1 soil-moisture visualization, MODIS NDVI and land-surface temperature. These are satellite image layers, not extracted measurements at the selected farm coordinates. Numeric SMAP point extraction through NASA AppEEARS and GPM IMERG point extraction still require a configured data-access workflow.</p>
          <div style={{display:"flex",gap:12,flexWrap:"wrap",marginTop:10,fontSize:10}}>
            <a href="https://appeears.earthdatacloud.nasa.gov/" target="_blank" rel="noreferrer">NASA AppEEARS <ExternalLink size={11}/></a>
            <a href="https://gpm.nasa.gov/data/directory" target="_blank" rel="noreferrer">NASA GPM IMERG <ExternalLink size={11}/></a>
            <a href="https://nasa-gibs.github.io/gibs-api-docs/access-basics/" target="_blank" rel="noreferrer">NASA GIBS docs <ExternalLink size={11}/></a>
          </div>
        </section>


        <section className="panel" style={{padding:"20px",marginBottom:15}}>
          <div className="panel-kicker">NASA / USGS DATA CATALOG · FARM MONITORING</div>
          <h2 style={{fontSize:18,margin:"7px 0"}}>SMAP & Landsat data resources</h2>
          <p style={{fontSize:12,color:"#849087",lineHeight:1.65,margin:"0 0 14px"}}>Official dataset discovery and access links for soil moisture and field-scale land monitoring. These resources are linked in the app; authenticated point extraction and derived farm metrics are not yet connected.</p>
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(230px,1fr))",gap:12}}>
            <article style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14,background:"#fbfcfa"}}>
              <div style={{fontSize:10,fontWeight:800,letterSpacing:".08em",color:"#438260"}}>NASA · SOIL MOISTURE</div>
              <h3 style={{fontSize:15,margin:"7px 0"}}>SMAP L3 Enhanced</h3>
              <p style={{fontSize:11,lineHeight:1.6,color:"#65736a",margin:"0 0 8px"}}>Product: SPL3SMP_E. Daily gridded surface and root-zone soil-moisture estimates; enhanced product at about 9 km. Use for regional soil-moisture context, with quality flags.</p>
              <div style={{fontSize:10,color:"#78857b",marginBottom:10}}>Access: NASA NSIDC / AppEEARS · Earthdata login may be required</div>
              <div style={{display:"flex",gap:12,flexWrap:"wrap",fontSize:11}}>
                <a href="https://nsidc.org/data/spl3smp_e" target="_blank" rel="noreferrer">Dataset details <ExternalLink size={11}/></a>
                <a href="https://appeears.earthdatacloud.nasa.gov/" target="_blank" rel="noreferrer">Point sampling <ExternalLink size={11}/></a>
              </div>
              <div style={{fontSize:10,fontWeight:700,color:"#a16d2c",marginTop:10}}>RESOURCE LINKED · numeric extraction pending</div>
            </article>
            <article style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14,background:"#fbfcfa"}}>
              <div style={{fontSize:10,fontWeight:800,letterSpacing:".08em",color:"#438260"}}>NASA / USGS · LANDSAT</div>
              <h3 style={{fontSize:15,margin:"7px 0"}}>Landsat 8–9 Collection 2 Level-2</h3>
              <p style={{fontSize:11,lineHeight:1.6,color:"#65736a",margin:"0 0 8px"}}>Surface reflectance and surface temperature products at 30 m. Useful for field-scale vegetation, bare-soil and thermal analysis; apply QA/cloud masks and scaling factors.</p>
              <div style={{fontSize:10,color:"#78857b",marginBottom:10}}>Access: USGS EarthExplorer · globally available, free data</div>
              <div style={{display:"flex",gap:12,flexWrap:"wrap",fontSize:11}}>
                <a href="https://www.usgs.gov/landsat-missions/landsat-collection-2-level-2-science-products" target="_blank" rel="noreferrer">Product guide <ExternalLink size={11}/></a>
                <a href="https://earthexplorer.usgs.gov/" target="_blank" rel="noreferrer">EarthExplorer <ExternalLink size={11}/></a>
              </div>
              <div style={{fontSize:10,fontWeight:700,color:"#a16d2c",marginTop:10}}>RESOURCE LINKED · scene processing pending</div>
            </article>
            <article style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14,background:"#fbfcfa"}}>
              <div style={{fontSize:10,fontWeight:800,letterSpacing:".08em",color:"#438260"}}>NASA · HARMONIZED LAND IMAGERY</div>
              <h3 style={{fontSize:15,margin:"7px 0"}}>HLS v2.0 (L30 + S30)</h3>
              <p style={{fontSize:11,lineHeight:1.6,color:"#65736a",margin:"0 0 8px"}}>Harmonized Landsat 8/9 and Sentinel-2 surface reflectance at 30 m, with roughly 1.4-day average revisit. HLS-VI includes NDVI and other vegetation indices.</p>
              <div style={{fontSize:10,color:"#78857b",marginBottom:10}}>Access: NASA Earthdata / LP DAAC / AppEEARS</div>
              <div style={{display:"flex",gap:12,flexWrap:"wrap",fontSize:11}}>
                <a href="https://hls.gsfc.nasa.gov/data-products/" target="_blank" rel="noreferrer">HLS products <ExternalLink size={11}/></a>
                <a href="https://hls.gsfc.nasa.gov/data-access-and-tools/" target="_blank" rel="noreferrer">Data access <ExternalLink size={11}/></a>
              </div>
              <div style={{fontSize:10,fontWeight:700,color:"#a16d2c",marginTop:10}}>RESOURCE LINKED · HLS data integration pending</div>
            </article>
          </div>
          <p style={{fontSize:10,color:"#8a948c",lineHeight:1.55,margin:"12px 0 0"}}>Important: SMAP is coarse relative to an individual field; Landsat/HLS offer finer spatial detail but are affected by clouds and revisit gaps. A linked catalog is not the same as downloaded or processed observations. No SMAP/Landsat measurements are currently fed into the crop recommendation score.</p>
        </section>


        <section className="panel" style={{padding:"20px",marginBottom:15}}>
          <div className="panel-header">
            <div>
              <div className="panel-kicker">EXPERIMENTAL TREND INDICATOR · NASA POWER OBSERVATIONS</div>
              <h2>Recent-condition risk indicator</h2>
              <p>Recent 14-day temperature and rainfall patterns, extrapolated as an indicative risk signal</p>
            </div>
            <span className="prototype-tag">NOT A WEATHER FORECAST</span>
          </div>
          {!outlook ? <div className="chart-empty">At least 7 valid daily NASA POWER observations are needed to calculate this outlook.</div> :
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(165px,1fr))",gap:12,marginTop:14}}>
              <div style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14}}>
                <div style={{fontSize:10,color:"#849087",fontWeight:700,letterSpacing:".06em"}}>COMBINED STRESS SIGNAL</div>
                <div style={{fontSize:30,fontWeight:800,color:outlook.combined>=70?"#b65c43":outlook.combined>=40?"#b18135":"#438260",marginTop:5}}>{outlook.combined}<small style={{fontSize:12,color:"#849087"}}>/100</small></div>
                <b style={{fontSize:12}}>{outlook.level} risk</b>
                <div style={{height:6,background:"#edf1ed",borderRadius:8,marginTop:10,overflow:"hidden"}}><div style={{height:"100%",width:`${outlook.combined}%`,background:outlook.combined>=70?"#c8785f":outlook.combined>=40?"#d4a34d":"#65a77c"}}/></div>
              </div>
              <div style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14}}>
                <div style={{fontSize:10,color:"#849087",fontWeight:700,letterSpacing:".06em"}}>TEMPERATURE TREND ESTIMATE</div>
                <div style={{fontSize:26,fontWeight:800,marginTop:5}}>{fmt(outlook.projectedMeanTemp)}<small style={{fontSize:12,color:"#849087"}}> °C</small></div>
                <div style={{fontSize:11,color:"#65736a",marginTop:5}}>{outlook.direction}</div>
                <div style={{fontSize:10,color:"#849087",marginTop:5}}>Heat-risk indicator: {outlook.heatRisk}/100</div>
              </div>
              <div style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14}}>
                <div style={{fontSize:10,color:"#849087",fontWeight:700,letterSpacing:".06em"}}>RAINFALL PERSISTENCE BASELINE</div>
                <div style={{fontSize:26,fontWeight:800,marginTop:5}}>{fmt(outlook.projected7DayRain)}<small style={{fontSize:12,color:"#849087"}}> mm / 7d</small></div>
                <div style={{fontSize:11,color:"#65736a",marginTop:5}}>Based on recent daily mean, not forecast rainfall</div>
                <div style={{fontSize:10,color:"#849087",marginTop:5}}>Dry-spell indicator: {outlook.dryRisk}/100</div>
              </div>
              <div style={{border:"1px solid #e5ebe5",borderRadius:12,padding:14}}>
                <div style={{fontSize:10,color:"#849087",fontWeight:700,letterSpacing:".06em"}}>OBSERVATION COVERAGE</div>
                <div style={{fontSize:16,fontWeight:800,marginTop:9}}>{outlook.confidence}</div>
                <div style={{fontSize:11,color:"#65736a",marginTop:6}}>{outlook.observations} recent daily observations</div>
                <div style={{fontSize:10,color:"#849087",marginTop:5}}>Recent dry days (&lt;1 mm): {outlook.dryDays}/14</div>
              </div>
            </div>
          }
          <div style={{fontSize:10,color:"#8a948c",lineHeight:1.65,marginTop:13,borderTop:"1px solid #edf0ed",paddingTop:11}}>
            Method: experimental linear temperature-trend extrapolation plus a rainfall-persistence baseline from up to 14 recent NASA POWER daily observations. Crop-specific heat thresholds and combined risk weights are demonstration assumptions, not calibrated agronomic parameters. SMAP soil moisture and Landsat/HLS vegetation measurements are not yet numeric model inputs; this indicator is not a weather forecast and no yield, irrigation, or disease prediction is claimed.
          </div>
        </section>

        <section className="panel" style={{padding:"20px",marginBottom:15}}>
          <div className="panel-header">
            <div><div className="panel-kicker">RULE-BASED CROP INTELLIGENCE</div><h2>Crop stress & suitability assessment</h2><p>Transparent screening using NASA weather and optional measured farm inputs</p></div>
            <span className="prototype-tag">RULE-BASED · NO TRAINING REQUIRED</span>
          </div>
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(170px,1fr))",gap:10,marginTop:14}}>
            <div style={{border:"1px solid #e5ebe5",borderRadius:10,padding:12}}><b style={{fontSize:12}}>Crop stress assessment</b><div style={{fontSize:11,color:"#438260",marginTop:6}}>Rule-based screening · active</div></div>
            <div style={{border:"1px solid #e5ebe5",borderRadius:10,padding:12}}><b style={{fontSize:12}}>Crop suitability index</b><div style={{fontSize:11,color:"#438260",marginTop:6}}>0–100 screening index · active</div></div>
          </div>
          <div style={{fontSize:11,color:"#65736a",margin:"14px 0 9px"}}>Optional: enter measured soil moisture (m³/m³) and satellite-derived NDVI. Leave blank if you do not have verified measurements.</div>
          <div className="filters" style={{marginTop:0}}>
            <label>SMAP / farm soil moisture (m³/m³)<input type="number" min="0" max="1" step="0.01" placeholder={nasaObs?.summary?.smap_rootzone_soil_moisture_m3_m3 != null ? `NASA root-zone ${Number(nasaObs.summary.smap_rootzone_soil_moisture_m3_m3).toFixed(2)} · optional override` : "Fetch NASA observations or enter measured value"} value={soilMoisture} onChange={e=>setSoilMoisture(e.target.value)}/></label>
            <label>NDVI mean<input type="number" min="-1" max="1" step="0.01" placeholder="e.g. 0.62" value={ndviMean} onChange={e=>setNdviMean(e.target.value)}/></label>
            <label>NDVI change<input type="number" min="-2" max="2" step="0.01" placeholder="e.g. -0.08" value={ndviChange} onChange={e=>setNdviChange(e.target.value)}/></label>
          </div>
          <div style={{display:"flex",gap:10,alignItems:"center",flexWrap:"wrap",marginTop:12}}>
            <button className="primary-btn" onClick={assessCropConditions} disabled={assessmentBusy || !weather}><Activity size={15}/>{assessmentBusy?"Calculating assessment…":"Assess crop conditions"}</button>
            <span style={{fontSize:10,color:"#849087"}}>Weather features use the selected NASA POWER date range ({range} days).</span>
          </div>
          {assessmentMessage && <div className="error-banner" style={{marginTop:12}}><ShieldAlert size={16}/><span>{assessmentMessage}</span></div>}
          {assessmentResult && <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(220px,1fr))",gap:12,marginTop:14}}>
            <div style={{border:"1px solid #dce9df",borderRadius:12,padding:14}}><div className="panel-kicker">CROP STRESS ASSESSMENT</div><div style={{fontSize:25,fontWeight:800,marginTop:5}}>{assessmentResult.stress.prediction}</div><div style={{fontSize:11,color:"#65736a",marginTop:5}}>Screening score: {fmt(assessmentResult.stress.score,0)}/100</div><div style={{fontSize:10,color:"#849087",marginTop:8}}>{assessmentResult.stress.reasons.join(" · ")}</div></div>
            <div style={{border:"1px solid #dce9df",borderRadius:12,padding:14}}><div className="panel-kicker">CROP SUITABILITY INDEX</div><div style={{fontSize:25,fontWeight:800,marginTop:5}}>{fmt(assessmentResult.yield.suitability_index,0)} <small style={{fontSize:12}}>/100</small></div><div style={{fontSize:10,color:"#849087",marginTop:8}}><b>{assessmentResult.yield.category}</b><div style={{fontSize:10,color:"#849087",marginTop:6}}>{assessmentResult.yield.warning}</div></div>
          </div>}
          <div style={{fontSize:10,color:"#8a948c",lineHeight:1.6,marginTop:13,borderTop:"1px solid #edf0ed",paddingTop:10}}>Method note: this is a transparent rule-based screening heuristic, not machine learning. Thresholds are demonstration assumptions and must be calibrated with local agronomic expertise. The suitability index is not predicted yield. Do not interpret it as irrigation advice, crop-loss probability or a validated diagnosis.</div>
        </section>

        <section className="panel" id="settings" style={{padding:"18px 20px",marginBottom:15}}>
          <div className="panel-kicker">WORKSPACE CONFIGURATION</div>
          <h2 style={{fontSize:17,margin:"7px 0"}}>Settings & service status</h2>
          <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(190px,1fr))",gap:12,marginTop:12}}>
            <div><b style={{fontSize:12}}>Backend API</b><p style={{fontSize:11,color:"#65736a",margin:"5px 0"}}>{apiBase}</p><span style={{fontSize:10,color:apiStatus === "online" ? "#438260" : "#a16d2c"}}>{apiStatus === "online" ? "Connected · healthy" : apiStatus === "checking" ? "Checking connection…" : "Offline · start backend"}</span></div>
            <div><b style={{fontSize:12}}>NASA POWER</b><p style={{fontSize:11,color:"#65736a",margin:"5px 0"}}>{weather?`${weather.count} observations loaded`:"No weather observations loaded"}</p><span style={{fontSize:10,color:weather?"#438260":"#a16d2c"}}>{weather?"Data received":"Check internet and refresh"}</span></div>
            <div><b style={{fontSize:12}}>Decision engine</b><p style={{fontSize:11,color:"#65736a",margin:"5px 0"}}>Rule-based screening active</p><span style={{fontSize:10,color:"#a16d2c"}}>No training dataset required; validate thresholds locally</span></div>
          </div>
          <div style={{fontSize:10,color:"#849087",marginTop:12}}>Change the API URL with VITE_API_BASE_URL in a local .env file. No API keys are embedded in this frontend.</div>
        </section>

        <section className="panel" id="nasa-earth-data" style={{padding:"18px 20px",marginBottom:15}}>
          <div className="panel-kicker">NASA EARTH OBSERVATIONS · LIVE DATA</div>
          <h2 style={{fontSize:17,margin:"7px 0"}}>NASA climate + SMAP soil-moisture observations</h2>
          <p style={{fontSize:11,color:"#65736a",lineHeight:1.6}}>Fetches a 30-day point time series for the selected farm coordinates. NASA POWER provides agroclimate variables; its Hydrology community exposes SMAP L4 surface and root-zone soil moisture parameters. Once fetched, root-zone moisture can feed the rule-based crop assessment and rotation ranking automatically (unless you override it with a manual value).</p>
          <button className="primary-btn" onClick={loadNasaObservations} disabled={nasaObsBusy}>{nasaObsBusy?"Loading NASA observations…":"Fetch NASA POWER + SMAP data"}</button>
          {nasaObsError && <div className="error-banner" style={{marginTop:10}}>{nasaObsError}</div>}
          {nasaObs && <div style={{marginTop:14}}>
            <div style={{fontSize:10,color:"#65736a",marginBottom:9}}>Valid observation days: {nasaObs.valid_observation_days} · {nasaObs.requested_period.start} to {nasaObs.requested_period.end}</div>
            <div style={{display:"grid",gridTemplateColumns:"repeat(auto-fit,minmax(145px,1fr))",gap:9}}>
              {[
                ["Mean air temperature",nasaObs.summary.temp_c,"°C"],
                ["Mean daily rainfall",nasaObs.summary.rain_mm_day,"mm/day"],
                ["Surface soil moisture",nasaObs.summary.smap_surface_soil_moisture_m3_m3,"m³/m³"],
                ["Root-zone soil moisture",nasaObs.summary.smap_rootzone_soil_moisture_m3_m3,"m³/m³"],
                ["Solar radiation",nasaObs.summary.solar_mj_m2_day,"MJ/m²/day"]
              ].map(([label,value,unit])=><div key={label} style={{border:"1px solid #dce9df",borderRadius:10,padding:11}}><div style={{fontSize:10,color:"#65736a"}}>{label}</div><b style={{fontSize:19}}>{value===null||value===undefined?"No data":Number(value).toFixed(3)} <small style={{fontSize:10}}>{unit}</small></b></div>)}
            </div>
            <div style={{fontSize:10,color:"#65736a",lineHeight:1.6,marginTop:10}}>Sources: NASA POWER Daily API and NASA SMAP L4 via POWER HY. SMAP is approximately 9 km resolution, not a field-scale soil test. Missing observations are not imputed. Use local soil samples for farm-level validation.</div>
          </div>}
          <div style={{display:"flex",gap:10,flexWrap:"wrap",marginTop:12,fontSize:10}}>
            <a href="https://power.larc.nasa.gov/docs/services/api/temporal/daily/" target="_blank" rel="noreferrer">NASA POWER API documentation ↗</a>
            <a href="https://power.larc.nasa.gov/docs/methodology/data/sources_hydrology/" target="_blank" rel="noreferrer">NASA SMAP / Hydrology sources ↗</a>
            <a href="https://lpdaac.usgs.gov/products/mod13q1v061/" target="_blank" rel="noreferrer">MODIS MOD13Q1 NDVI dataset ↗</a>
            <a href="https://gpm.nasa.gov/data/imerg" target="_blank" rel="noreferrer">NASA GPM IMERG ↗</a>
          </div>
        </section>

        <section className="source-strip">
          <div><div className="panel-kicker">DATA TRANSPARENCY</div><h3>Built around open Earth data</h3><p>Live numeric point data: NASA POWER. NASA GIBS satellite layers are visual overlays; they are not farm-point measurements.</p></div>
          <div className="source-badges"><a href="https://power.larc.nasa.gov/" target="_blank" rel="noreferrer">NASA POWER <ExternalLink size={12}/></a><span>SMAP · GIBS visual layer</span><span>MODIS NDVI / LST · GIBS visual layers</span><a href="https://gpm.nasa.gov/data/directory" target="_blank" rel="noreferrer">GPM IMERG · official data <ExternalLink size={12}/></a></div>
        </section>
        <footer><span>FIELDSHIFT AI <i>·</i> Prototype for NASA Space Apps Challenge 2026</span><span>{lastUpdated?`Last data update: ${lastUpdated}`:"Data not yet loaded"} <i>·</i> Not an operational agronomic advisory</span></footer>
      </div>
    </main>
  </div>;
}
