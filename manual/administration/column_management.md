# Column Management Guide

This guide provides instructions on how to add or delete columns in different table types using the `manage_column.sh` script.

## Getting Started

Before running any commands, navigate to the script directory:

```bash
cd /opt/seaticket/seaqa-indexer/seaqa_indexer/script
```

---

## 1. Connection Table Operations

Use these commands to manage columns for tables with the `connection` type (e.g., `seafile`).

### Delete a Column
To remove an existing column, use the `delete-column` action:
```bash
./manage_column.sh delete-column \
    --table-name seafile \
    --table-type connection \
    --column-name test1
```

### Add a Column
To add a new column, specify the column name, type, and data mapping:
```bash
./manage_column.sh add-column \
    --table-name seafile \
    --table-type connection \
    --column-name test1 \
    --column-type list \
    --column-data-name list_int
```

---

## 2. Project Table Operations

Use these commands to manage columns for tables with the `project` type (e.g., `tickets`).

### Delete a Column
```bash
./manage_column.sh delete-column \
    --table-name tickets \
    --table-type project \
    --column-name test1
```

### Add a Column
```bash
./manage_column.sh add-column \
    --table-name tickets \
    --table-type project \
    --column-name test1 \
    --column-type list \
    --column-data-name list_int
```

---

## Command Reference

For detailed information on all available parameters and options, run the help command:

```bash
./manage_column.sh -h
```

### Parameter Overview:
- `--table-name`: The name of the target table (e.g., `seafile`, `tickets`).
- `--table-type`: The category of the table (`connection` or `project`).
- `--column-name`: The identifier for the column being modified.
- `--column-type`: The logical type of the column (e.g., `list`).
- `--column-data-name`: The underlying data structure type (e.g., `list_int`).