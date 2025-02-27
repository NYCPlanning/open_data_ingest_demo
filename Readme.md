
### Extract data with ingest tool by running this:
```bash
python3 -m dcpy.cli lifecycle ingest dpr_forever_wild -s
```

### Output files
- `config.json`: this is a metadata file about data and ingestion process. 
- `init.parquet`: raw data in parquet format
- `<dataset_id>.<format extension>`: raw data. Example: `dpr_forever_wild.zip`.
- `<dataset_id>.parquet`: output data. Example: `dpr_forever_wild.parquet`. If pre-processing steps were not specified in dataset template, then this file will be the same as `init.parquet`


### TODO before presentation:
- supply template dir path as an arg to the CLI. Similar to library (SF)
- Creating a sample dir with a couple of templates and instructions to run CLI (SF)
    - 2 socrata (NYC and NYS), arcgis, bpl libraries templates
- Cleaning up CLI args (like making -s flag default)
- Create jupyter notebook (ideas what to show about ingest)
