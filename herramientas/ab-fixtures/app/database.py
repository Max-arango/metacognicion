import json
import os


def _db_path():
    d = os.environ.get("DB_DIR", ".ab_data")
    return os.path.join(d, "db.json")


def save(record):
    path = _db_path()
    os.makedirs(os.path.dirname(path), exist_ok=True)
    data = {}
    if os.path.exists(path):
        with open(path) as f:
            data = json.load(f)
    key = str(record.get("id"))
    data[key] = record
    with open(path, "w") as f:
        json.dump(data, f)
    return True


def load():
    path = _db_path()
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        return json.load(f)
