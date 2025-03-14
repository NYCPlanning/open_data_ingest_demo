# Overview
This tool ingests data from external sources or a local machine, optionally transforms/cleans the data, and stores the result in Parquet files. It supports both geospatial and non-geospatial datasets.


### Extract data with ingest tool by running this:
```bash
python3 -m dcpy.cli lifecycle ingest dpr_forever_wild -s
```

### Ingest tool in action
```mermaid
flowchart LR
  B[Raw data]
  n1@{ shape: "tri", label: "Local File" } -->  B
  n2@{ shape: "tri", label: "API" } -->  B
  n3@{ shape: "tri", label: "Open Data" } --> |Extract to local machine| B
  n4@{ shape: "tri", label: "ArcGIS Server" }--> B
  n5@{ shape: "tri", label: "S3" } -->  B
  
  B -->|Convert to parquet| C[init.parquet]

  %%C --> D{Pre-processing steps specified?}
  %%D -- Yes --> E[Apply pre-processing steps]
  %%E --> F[dataset_id.parquet]
  %%D -- No --> F

  E[dataset_id.parquet]
  C -->|No change| E
  C -->|Apply pre-processing steps| E
```

### Output files
- `config.json`: this is a metadata file about data and ingestion process. 
- `init.parquet`: raw data in parquet format
- `<dataset_id>.<format extension>`: raw data. Example: `dpr_forever_wild.zip`.
- `<dataset_id>.parquet`: output data. Example: `dpr_forever_wild.parquet`. If pre-processing steps were not specified in dataset template, then this file will be the same as `init.parquet`


# Quick Start Guide

## Installation
Ensure you have Python and git installed, then install the ingest package:

```bash
python -m pip install git+https://github.com/NYCPlanning/data-engineering@main
```

## Steps to Ingest Data
### 1. Create a YAML Ingest Config File
Each dataset requires a YAML configuration file defining its ingestion settings. Below are the required fields.

### **Shared Required Fields**
```yaml
id: <unique_dataset_id>  # Unique identifier for the dataset. It must match with its config filename like <unique_dataset_id>.yml
acl: public-read  # Access control level (`public-read` or `private`)

attributes:
  name: <dataset name>  # Human-readable name of the dataset

ingestion:
  source: <source details>  # Specifies the data source, see next section 
  file_format: <format details>  # Defines the file format of the source data, seen section below
```

### **Required Fields by Source Type**

<details>
<summary><strong>From local file</strong></summary>

This option assumes that you already have dataset of interest on your local machine. 

```yaml
source:
  type: local_file
  path: <path to local file>
```

Example: 
```yaml
source:
  type: local_file
  path: path/to/my/dataset.csv
```

</details>

<details>
<summary><strong>From OpenData portal</strong></summary>

Pull data from OpenData. To find `org` and `uid` values for a given dataset, refer to OpenData portal dataset's url. Though source `format` is specified, the `file_format` section is still required. 

```yaml
source:
  type: socrata
  org: <organization>  # Allowed values are: `nyc`, `nys`, and `nys_health`
  uid: <dataset identifier>  # Dataset identifier
  format: <file format>  # Data format of the source file. Allowed values are: `csv`, `geojson`, and `shapefile`
```

Examples:

```yaml
# DPR Parks roperties: https://data.cityofnewyork.us/Recreation/Parks-Properties/enfh-gkve
source:
  type: socrata
  org: nyc
  uid: enfh-gkve
  format: geojson
```

```yaml
# Solid Waste Management Facilities: https://data.ny.gov/Energy-Environment/Solid-Waste-Management-Facilities/2fni-raj8
source:
  type: socrata
  org: nys
  uid: 2fni-raj8
  format: csv
```

</details>


<details>
<summary><strong>From Esri Feature Service</strong></summary>

```yaml
source:
  type: esri
  server: <server name>  # Allowed values are: `nys_clearinghouse`, `nys_parks`, `nps`, `dcp`, and `nyc_maphub`
  dataset: <dataset name>  # Name of the Esri dataset
  layer_id: <layer_id>  # ID of the layer (only specified if the dataset has multiple layers)
```

Example: 

```yaml
#  National Register of Historic Places: https://services.arcgis.com/1xFZPtKn1wKC6POA/ArcGIS/rest/services/National_Register_Building_Listings/FeatureServer
source:
	type: esri
	server: nys_parks
	dataset: National_Register_Building_Listings
	layer_id: 13
```

</details>


<details>
<summary><strong>From API</strong></summary>
Pull data from an API. Currently available for datasets in `csv` and `json` file formats. Though source `format` is specified, the `file_format` section is still required. 

```yaml
source:
  type: api
  endpoint: <api endpoint> 
  format: <file format>  # Must be `csv` or `json` 
```

Example:

```yaml
# NY Public Libraries: https://www.nypl.org/locations
source:
	type: api
	endpoint: https://refinery.nypl.org/api/nypl/locations/v1.0/locations
	format: json
```

</details>


### **Required Fields by Data Format Type**

<details>
<summary><strong>In csv</strong></summary>

```yaml
file_format:
  type: csv
  geometry: <geometry details>  # Only required if dataset is geospatial (see section below). Otherwise can be ommitted 
```

Examples:

```yaml
# Non-geospatial dataset
file_format:
  type: csv
```

```yaml
# Non-geospatial dataset with some optional attributes
file_format:
  type: csv
	encoding: utf-8
	delimiter: "|"
	column_names: ["Column 1", "Column 2"]	 # When data doesn't have headers, add new ones 
```

```yaml
# Geospatial dataset with geometry stored in "Longitude" and "Latitude" columns
file_format:
  type: csv
	geometry:
		geom_column:
			x: Longitude
			y: Latitude
		crs: EPSG:4326
```

```yaml
# Geospatial dataset with geometry in "GEOM" column
file_format:
  type: csv
	geometry:
		geom_column: GEOM
		crs: EPSG:2263
		format: wkb
```

</details>

<details>
<summary><strong>In excel</strong></summary>

```yaml
file_format:
  type: xlsx  # The value can also be `excel`
  sheet_name: <excel sheet name or number>
  geometry: <geometry details>  # Only required if dataset is geospatial (see section below). Otherwise can be ommitted 
```

Examples:

```yaml
# Non-geospatial dataset
file_format:
	type: xlsx
	sheet_name: Sheet_1
```

```yaml
# Geospatial dataset with geometry in "wkb_geometry" column
file_format:
	type: xlsx
	sheet_name: Sheet_1
	geometry:
		geom_column: wkb_geometry
		crs: EPSG:2263
```

</details>

<details>
<summary><strong>In Json</strong></summary>

```yaml
file_format:
  type: json
  json_read_fn: <json_read_fn>  # Allowed values: `normalize`, `read_json`. These are pandas functions to read in a json file -- refer to pandas docs for more details
  geometry: <geometry details>  # Only required if dataset is geospatial (see section below). Otherwise can be ommitted 
```

Examples:

```yaml
# Non-geospatial dataset of Brooklyn Libraries: https://www.bklynlibrary.org/locations
file_format:
  type: json
  json_read_fn: normalize
  json_read_kwargs: { "record_path": [ "locations" ] }
```

```yaml
# Geospatial dataset with geometry stored in "Longitude" and "Latitude" columns
file_format:
  type: json
  json_read_fn: normalize
  json_read_kwargs:
    {
      "record_path": ["Locations", "Location"],
      "meta": ["TrackerID", "FMSID", "Title", "TotalFunding"],
    }
  geometry:
    crs: EPSG:4326
    geom_column:
      x: Longitude
      y: Latitude
```

</details>

<details>
<summary><strong>In GeoJson</strong></summary>
Note, crs is not an attribute for geojson format. Geojson has a specification of "EPSG:4326"

```yaml
file_format:
  type: geojson
```

Example:

```yaml
file_format:
  type: geojson
```

</details>

<details>
<summary><strong>In shapefile</strong></summary>

```yaml
file_format:
  type: shapefile
  crs: <crs>  # Coordinate Reference System. Ex: `EPSG:4326`
```

Example:

```yaml
file_format:
  type: shapefile
  crs: EPSG:2263
```

</details>

<details>
<summary><strong>In geodatabase</strong></summary>

```yaml
file_format:
  type: geodatabase
  crs: <crs>  # Coordinate Reference System. Ex: `EPSG:4326`
  layer: <layer name>  # Only required if the file contains multiple layers. Otherwise can be ommitted 
```

Examples:

```yaml
# Geodatabase file with one layer
file_format:
  type: geodatabase
  crs: EPSG:2263
```

```yaml
# Geodatabase file with multiple layers. Pick `lion` layer
file_format:
  type: geodatabase
  layer: lion
  crs: EPSG:2263
```


</details>


### 2. Run the Ingest Command
Once your YAML file is ready, run the following command:

```bash
python3 -m dcpy.cli lifecycle ingest <unique_dataset_id> --template-dir <directory path> -s
```

### 3. Output
Processed data is saved as a Parquet file in the designated output directory.

## Additional Options
- **Transformations**: You can specify optional `processing_steps` for column renaming, cleaning, and more.
- **Geospatial Data**: Define geospatial info in `geometry` property under `file_format` property.

