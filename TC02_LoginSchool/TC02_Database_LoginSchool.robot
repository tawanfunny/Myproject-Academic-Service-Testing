*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Library    Collections
Resource    KeywordTC02_Database.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC02_LoginSchool/02_Database_LoginSchool.xlsx   
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    7
${cols}    8

*** Test Cases ***
TC02: 02_Database_LoginSchool
    [Documentation]    Test_02_Database_LoginSchool
    [Tags]    Login_Database_School
    Set Selenium Speed    1
    Go To Academic_Services    ${datatable}

    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run Database_LoginSchool   ${i}
    END       
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document
    