*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC09_ActionAlertMessage.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC09_SelectRequest/09_ActionAlertMessage_SelectRequest.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    2
${cols}    8



*** Test Cases ***
TC09: 09_SelectRequest
    [Documentation]    Test_09_ActionAlertMessage_SelectRequest
    [Tags]    ActionAlertMessage_SelectRequest
    Set Selenium Speed    3
    Open Excel Document    ${datatable}    TC09-EC 
    
    FOR     ${i}    IN RANGE    2    ${rows}+1
        Clear Select Data In DB    ${i}
        Go To Academic_Services    ${i}
        Login As Student
        Click Select Button And Capture Alert    ${i}
        Compare And Write Result To Excel   ${i}   
    END
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document