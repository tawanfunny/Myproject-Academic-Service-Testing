*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Resource    KeywordTC03.robot

*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC03_RequestService/03_Data_RequestService.xlsx  
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${rows}    48
${cols}    13


*** Test Cases ***
TC03: 03_Data_RequestService
    [Documentation]    Test_03_Data_RequestService
    [Tags]    Request_Service
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run Request_Service    ${i} 
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document