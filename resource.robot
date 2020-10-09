*** Settings ***
Documentation    Provides keywords for accessing and retrieving iphone data from flipkart
Library          Selenium2Library
Library          Collections
Library          String
Library          Utility.py
Resource         configuration.robot

*** Variables ***
${SEARCH TEXTBOX}           name:q
${SEARCH BUTTON}            xpath://button[@type='submit']
${PRICE RANGE DROPDOWN}     xpath:(//select)[2]
${DROPDOWN OPTIONS}         (//select)[2]//option
${BUTTONS}                  xpath://button
${POP UP CLOSE BUTTON}      xpath:(//button)[2]
${RETRY_ATTEMPTS}           10    
${RETRY_AFTER}              1
${SEARCH RESULT ROW}        (//div[contains(@class,'row')])
${SEARCH RESULTS COUNT}     xpath://span[contains(text(),'Showing')]
${PAGES COUNT}              xpath://a[contains(@href,'page=')]
@{data}=    

*** Keywords ***
Open Flipkart Homepage
    [Documentation]    Opens Flipkart homepage
    Open Browser    ${FLIPKART URL}    ${BROWSER}

Check for Popup
    [Documentation]    Check for the presence of login popup
    ${buttons list}=    Get WebElements    ${BUTTONS}
    ${buttons count}=    Get Length    ${buttons list}
    Run Keyword If    ${buttons count}>1    Wait for popup to close

Wait for popup to close
    [Documentation]    Attempts to close popup
    Wait Until Keyword Succeeds    ${RETRY_ATTEMPTS}    ${RETRY_AFTER}    Identify and close popup

Identify and close popup
    [Documentation]    Identify pop up close button and closes it
    Wait Until Element Is Enabled    ${POP UP CLOSE BUTTON}
    Set Focus To Element    ${POP UP CLOSE BUTTON}
    Click Element    ${POP UP CLOSE BUTTON}

Search for Iphone
    [Documentation]    Enters search text
    Input Text    ${SEARCH TEXTBOX}    ${SEARCH TEXT}
    Click Button    ${SEARCH BUTTON}
    
Select Price Range
    [Documentation]    Selects price range based on MAX PRICE
    Wait Until Element Is Visible    ${PRICE RANGE DROPDOWN}
    ${dropdown options list}=    Get WebElements      ${DROPDOWN OPTIONS}
    FOR    ${option}    IN    @{dropdown options list}
        ${value}=    Get Element Attribute    ${option}   value 
        Continue For Loop If    ${value} < ${MAX PRICE}
        Select From List By Value    ${PRICE RANGE DROPDOWN}    ${value}
        Exit For Loop
    END

Select Page
    [Documentation]    Changes Pages and gets data from search results
    ${pages}=    Get WebElements    ${PAGES COUNT}
    FOR    ${page}    IN    @{pages}
        ${status}=    Run Keyword And Return Status    Find and click page    ${page}
        Exit For Loop If    ${status}=='FAIL'
        ${status}=    Run Keyword And Return Status    Get Details
        Exit For Loop If    ${status}=='FAIL'
    END

Find and click page
    [Documentation]    Changes page number
    ...                ${page} is the page element
    [Arguments]    ${page}
    Scroll Element Into View    ${page}
    Wait Until Element is visible    ${page}     timeout=5s
    Set Focus To Element    ${page}    
    Wait Until Keyword Succeeds    ${RETRY_ATTEMPTS}    ${RETRY_AFTER}    Click Element    ${page}

Get results count
    [Documentation]    Returns total number of results displayed
    Scroll Element Into View    ${SEARCH RESULTS COUNT}
    Wait Until Element is visible    ${SEARCH RESULTS COUNT}     timeout=5s
    ${showing count label}=    Get Text    ${SEARCH RESULTS COUNT}
    ${tokens}=    Split String    ${showing count label}    ${SPACE}
    ${row max}=    Get From List    ${tokens}    3
    ${row min}=    Get From List    ${tokens}    1
    ${row max}=    Convert To Integer    ${row max}
    ${row min}=    Convert To Integer    ${row min}
    ${row count}=  Evaluate    ${row max}-${row min}
    [Return]    ${row count}

Get Details
    [Documentation]    Gets the Model Name, Price and Ratings from search results
    ${row count}=    Get results count
    FOR    ${el}    IN RANGE    1    ${row count}+2
        ${price}=    Wait Until Keyword Succeeds    5    1    Get model price    ${el}  
        Continue For Loop If    ${price}>${MAX PRICE}
        ${model name}=    Wait Until Keyword Succeeds    5    1    Get model name    ${el}
        ${ratings}=    Wait Until Keyword Succeeds    5    1    Get model ratings    ${el}
        Create and append to data    ${model name}    ${price}    ${ratings}
    END  

Get model name
    [Documentation]    Returns model name
    [Arguments]    ${el}
    ${model name}=    Get Text    xpath:${SEARCH RESULT ROW}\[${el}]/div[1]/div
    [Return]    ${model name}

Get model ratings
    [Documentation]    Returns ratings
    [Arguments]    ${el}
    ${ratings}=    Get Text    xpath:${SEARCH RESULT ROW}\[${el}]/div[1]/div[2]/span/span/span[1]
    ${ratings}=    Split String    ${ratings}    ${SPACE}
    ${ratings}=    Get From List    ${ratings}    0
    [Return]    ${ratings}

Get model price
    [Documentation]    Returns Price
    [Arguments]    ${el}
    ${price}=    Get Text    xpath:${SEARCH RESULT ROW}\[${el}]/div[2]/div[1]/div/div[1]
    ${price}=    Get Substring    ${price}    1
    ${price}=    Remove String    ${price}    ,         
    [Return]    ${price}

Create and append to data
    [Documentation]    Creates dictionary of phone detail then appends it to list
    [Arguments]    ${model name}    ${price}    ${ratings}
        ${dict}=    Create Dictionary
        Set To Dictionary    ${dict}    Device Details    ${model name}
        Set To Dictionary    ${dict}    Price    ${price}
        Set To Dictionary    ${dict}    Ratings    ${ratings}  
        Append To List    ${data}    ${dict}

Sort and Write to csv
    [Documentation]    Sorts data based on price and then saves it to csv file
    Sort And Save    ${data}

