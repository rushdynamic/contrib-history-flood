### Usage

`./contrib_flood.sh -r <repo_url> -s <start_date> [-e <end_date>] [--fuzzy]`

```
Options:
-r <repo_url> Repository URL (required).
-s <start_date> Start date in the format `dd-mm-yyyy` (required).
-e <end_date> End date in the format `dd-mm-yyyy` for using a date-range (optional).
--fuzzy Enable fuzzy date selection from given range (optional).
```

Example: `./contrib_flood.sh https://github.com/rushdynamic/dummy-repo.git -s 22-02-2024 -e 25-02-2024 --fuzzy`
