# DNSMon

This simple tool uses amass and cronjobs to continiously monitor domains on some targets.

## How to Use

1. Write a targets.txt file under a day's folder. E.g, `touch Monday/targets.txt`.
2. In the targets.txt file, write the path to a project directory.
3. In the project directory, there should be a subdirectory called DNS.
4. The DNS project subdirectory should have a the following:
    * `amass.ini`: Amass config file.
    * `root_domains.txt`: A list of root domains in scope for this target.
    * `amass_dir/`: An amass project directory.
5. Run the following amass command in the DNS project subdirectory: `amass enum -src -active -df root_domains.txt -config amass.ini -o amass_results.txt -dir amass_dir -brute -norecursive`.
6. Copy `amass_results.txt` into `all_domains.txt`.
7. Set up a cronjob to run the thing.sh script in DNSMon to run daily: `0 8 * * * {{somewhere}}/thing.sh`

