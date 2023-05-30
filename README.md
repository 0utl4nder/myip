# NetSense

### This script automates the Local IP's and Private interfaces, data recolection

> _[invite me a coffee](https://www.paypal.com/donate/?hosted_button_id=9GUQPSB3SH63W)_

## Usage

> `-a check`

This will provide you all the data related with your detected active interfaces `name | IP | Broadcast | Mac Address` , and your detected Local IP `IP | Country | City | ZIP (postal code) | ISP (internet service provider)`

> `-l [IP/check]`
>
> This will only provide you all the data related with the IP you have written.

-   Example
-   -   `netsense.sh -l 8.8.8.8` This will provide `Country | City | ZIP (postal code) | ISP (internet service provider)` of **that IP**

---

-   -   `netsense.sh -l 8.8.8.8,9.9.9.9` This will provide `Country | City | ZIP (postal code) | ISP (internet service provider)` of that **group of IP's**

---

-   -   `netsense.sh -l check` This will provide `IP | Country | City | ZIP (postal code) | ISP (internet service provider)` of the **IP which is able to detect** (yours)

> `-s [INTERFACE/check]`
>
> This will only provide you all the data related with the IP you have written.

-   Example
-   -   `netsense.sh -s eth0` This will provide `name | IP | Broadcast | Mac Address` of **that interface**

---

-   -   `netsense.sh -s eth0,wlo1` This will provide `name | IP | Broadcast | Mac Address` of that **group of interfaces**

---

-   -   `netsense.sh -s check`This will provide `name | IP | Broadcast | Mac Address` of the **active interfaces which is able to detect** (yours)

![Picture](https://github.com/0utl4nder/myip/blob/main/myip.png?raw=true)
