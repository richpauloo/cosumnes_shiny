---
title: "research log"
output: html_notebook
author: Rich Pauloo
---

In this document, I'll keep a log of my activities so it's easy to follow what happened.  

***

February 21, 2018  

* performed load tests for the webapp on:  
    + googlesheets : failed  
    + github : passed

pros of using github: no need to set up remote DB  
cons of using github: the webapp is as real-time as the user who downloads, cleans, and uploads data from SQLite  


* successfully queried the SQlite database on Amy's computer using `RSQlite`.  
* the body of each email needs to cleaned for the appropriate data  
* determined that [AWS RDS](https://aws.amazon.com/rds/) is an option for remote storage  
* communicated with Mauricio and Solonist people to investigate remote DB options  

***

February 22, 2018  

* confirmed with Mauricio and Solonist that a remote DB is out of the question  
    + Solonist only offers SQLite, email and text notifications with the hardware we're using (level sender)  
* investiagted the potential of `gmailr` (access to gmail API) to query email data  
    + load test: failed  
        + 200 emails ~= 30 seconds  
        + 2000 emails ~= 300 seconds (5 minutes)  
* new plan:  
    + use either UCD servers or AAWS RDS to store clean data  
    + write an automated script that queries SQLite database daily, cleans data, and pushes it to the remote DB  
        + pros: very fast for webapp to access data, because the query is smaller, and we remove the cleaning step  
        + cons: technical to set up, but I love a new challenge  
* sent email to Chris to investigate if UCD can give us remote server space, and if not, if he recommends AWS RDS  
* found these resources in setting up an automated task in Windows  
    + [Stack Overflow question](https://stackoverflow.com/questions/2793389/scheduling-r-script)  
    + [blog post](https://www.techradar.com/news/software/applications/how-to-automate-tasks-in-windows-1107254)  

TO DO:  

* Amy:  
    + change the reporting interval from 6 hour intervals to 24 hour intervals to save battery life  
    + read up on strings to prepare for cleaning SQLite data  
* Rich:  
    + follow up with Chris  
    + set up the remote DB  

***

February 23, 2018  

* Talked with Omen (IT) and named project mySQL database "gw-observatory"  



    







