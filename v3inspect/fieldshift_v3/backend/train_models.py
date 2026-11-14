"""Train both FIELDSHIFT AI models from real, labelled CSV observations.

No synthetic training data is generated. The script stops if either labelled
training file is missing or too small, so placeholder/demo values cannot be
mistaken for a scientifically trained model.
"""
from pathlib import Path
import json
import sys
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.metrics import (accuracy_score, balanced_accuracy_score, classification_report,
                             mean_absolute_error, mean_squared_error, r2_score)
from sklearn.model_selection import GroupShuffleSplit, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer
import joblib
from model_config import FEATURES, NUMERIC_FEATURES, CATEGORICAL_FEATURES, STRESS_TARGET, YIELD_TARGET, MODEL_DIR

ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parent
DATA = PROJECT / "data"
MODELS = ROOT / MODEL_DIR
MIN_ROWS = 100


def load_dataset(filename: str, target: str):
    path = DATA / filename
    if not path.exists():
        raise FileNotFoundError(f"Missing {path}. Fill the matching CSV template with sourced, labelled observations.")
    df = pd.read_csv(path)
    missing = [c for c in FEATURES + [target] if c not in df.columns]
    if missing:
        raise ValueError(f"{filename} is missing required columns: {', '.join(missing)}")
    keep = FEATURES + [target] + (["location_id"] if "location_id" in df.columns else [])
    df = df[keep].copy()
    df["crop"] = df["crop"].astype("string").str.strip().str.title()
    for col in NUMERIC_FEATURES:
        df[col] = pd.to_numeric(df[col], errors="coerce")
    if target == YIELD_TARGET:
        df[target] = pd.to_numeric(df[target], errors="coerce")
    else:
        df[target] = df[target].astype(str).str.strip().str.title()
        df.loc[df[target].isin(["", "Nan", "None"]), target] = pd.NA
    df = df.dropna(subset=[target, "crop"])
    df = df[df["crop"].ne("")]
    if len(df) < MIN_ROWS:
        raise ValueError(f"{filename} has {len(df)} usable rows; at least {MIN_ROWS} labelled rows are required for this training run.")
    return df


def split_data(df, target, classification=False):
    # Prefer spatial holdout to test generalisation to unseen locations.
    if "location_id" in df.columns and df["location_id"].nunique() >= 3:
        splitter = GroupShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
        train_idx, test_idx = next(splitter.split(df, groups=df["location_id"].astype(str)))
        train, test = df.iloc[train_idx], df.iloc[test_idx]
    else:
        stratify = df[target] if classification and df[target].value_counts().min() >= 2 else None
        train, test = train_test_split(df, test_size=0.2, random_state=42, stratify=stratify)
    if classification and train[target].nunique() < 2:
        raise ValueError("Training split contains only one stress class. Provide balanced Low/Moderate/High labelled examples.")
    return train, test


def make_pipeline(classification):
    preprocess = ColumnTransformer([
        ("numeric", Pipeline([("imputer", SimpleImputer(strategy="median")), ("scale", StandardScaler())]), NUMERIC_FEATURES),
        ("crop", Pipeline([("imputer", SimpleImputer(strategy="most_frequent")), ("onehot", OneHotEncoder(handle_unknown="ignore"))]), CATEGORICAL_FEATURES),
    ])
    model = (RandomForestClassifier(n_estimators=500, min_samples_leaf=2, class_weight="balanced_subsample", random_state=42, n_jobs=-1)
             if classification else
             RandomForestRegressor(n_estimators=500, min_samples_leaf=2, random_state=42, n_jobs=-1))
    return Pipeline([("preprocess", preprocess), ("model", model)])


def train_one(filename, target, name, classification):
    df = load_dataset(filename, target)
    train, test = split_data(df, target, classification)
    pipeline = make_pipeline(classification)
    pipeline.fit(train[FEATURES], train[target])
    pred = pipeline.predict(test[FEATURES])
    if classification:
        metrics = {
            "accuracy": round(float(accuracy_score(test[target], pred)), 4),
            "balanced_accuracy": round(float(balanced_accuracy_score(test[target], pred)), 4),
            "classification_report": classification_report(test[target], pred, output_dict=True, zero_division=0),
        }
    else:
        metrics = {
            "mae_t_ha": round(float(mean_absolute_error(test[target], pred)), 4),
            "rmse_t_ha": round(float(mean_squared_error(test[target], pred) ** 0.5), 4),
            "r2": round(float(r2_score(test[target], pred)), 4) if len(test) > 1 else None,
        }
    metrics.update({"training_rows": int(len(train)), "test_rows": int(len(test)), "split": "location holdout" if "location_id" in df.columns and df["location_id"].nunique() >= 3 else "random holdout", "features": FEATURES, "target": target, "data_file": filename})
    MODELS.mkdir(exist_ok=True)
    joblib.dump({"pipeline": pipeline, "model_name": "RandomForestClassifier" if classification else "RandomForestRegressor", "training_rows": int(len(train))}, MODELS / f"{name}.joblib")
    (MODELS / f"{name}_metrics.json").write_text(json.dumps(metrics, indent=2))
    print(f"\n{name}: trained")
    print(json.dumps(metrics, indent=2))
    return metrics


if __name__ == "__main__":
    try:
        train_one("crop_stress_training.csv", STRESS_TARGET, "crop_stress", True)
        train_one("crop_yield_training.csv", YIELD_TARGET, "crop_yield", False)
        print("\nBoth models trained and saved in backend/models/. See metrics JSON files.")
    except Exception as exc:
        print(f"TRAINING STOPPED: {exc}", file=sys.stderr)
        sys.exit(1)
