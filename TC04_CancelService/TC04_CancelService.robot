*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Resource    KeywordTC04.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database

*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC04_CancelService/04_Data_CancelService.xlsx 
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    30
${cols}    11


*** Test Cases ***
TC04: 04_Data_CancelService
    [Documentation]    Test_04_Data_CancelService
    [Tags]    Cancel_Service
    Set Selenium Speed    1
    Go To Academic_Services    ${datatable}
    Go To Login Page
    Login As Member
    Go To Cancel Request Page

    FOR    ${i}    IN RANGE    2    ${rows}+2
        Run CancelService    ${i}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document

