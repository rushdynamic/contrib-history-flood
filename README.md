## About

This script allows you to add dummy GitHub contributions to past dates.\
You can specify either a single date in the past, or a date-range. There's also a `--fuzzy` option that can be used with date-ranges to make the contributions look more natural.

### Before

![Before](https://github.com/user-attachments/assets/c6fc9110-7743-4918-b219-5f458c411938)

### After

![After](https://github.com/user-attachments/assets/823e4926-7af7-4e0a-a22b-99511ab34681)

## Usage

`./contrib_flood.sh -r <repo_url> -s <start_date> [-e <end_date>] [--fuzzy]`

```
Options:
-r <repo_url> Repository URL (required).
-s <start_date> Start date in the format `dd-mm-yyyy` (required).
-e <end_date> End date in the format `dd-mm-yyyy` for using a date-range (optional).
--fuzzy Enable fuzzy date selection from given range (optional).
```

**Step 1.** Create a dummy repository on GitHub (preferrably private).\
**Step 2.** Run the script and provide the url to the dummy repo, along with the other args mentioned above, and you're done.

Example:

```
./contrib_flood.sh https://github.com/rushdynamic/dummy-repo.git -s 01-01-2019 -e 31-12-2019 --fuzzy
```

NOTE: Verify that your terminal instance is configured to use your appropriate GitHub credentials by running `git config --list` first.

## How to rollback

Simply delete the dummy repository that you created and your dummy contributions would be gone with it.

### **PS**: I wrote this script primarily for my personal amusement, and to see if it would actually work. Faking GitHub contributions is pretty much meaningless, and I don't really advise anyone to actually do it.
