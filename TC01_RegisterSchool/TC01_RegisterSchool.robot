*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC01.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database






*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC01_RegisterSchool/01_Data_RegisterSchool.xlsx 
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    112
${cols}    18


*** Test Cases ***
TC01: 01_Data_RegisterSchool  
    [Documentation]    Test_01_Data_RegisterSchool
    [Tags]    Regsiter_School
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Clear Register_School Data In DB     ${i}
        Run Register_School    ${i}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document
    
