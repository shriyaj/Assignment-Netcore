*** Settings ***
Documentation      Search and Retrieves Iphone data from flipkart then sort and saves it
Resource           resource.robot
Suite Setup        Open Flipkart Homepage
Suite Teardown     Close Browser

*** Test Cases ***
Save Iphone Data Sorted To CSV
    Check for Popup
    Search for Iphone
    Select Price Range
    Select Page
    Sort and Write to csv
