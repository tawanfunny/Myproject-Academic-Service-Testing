*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC06.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC06_EditProfile/06_Data_EditProfile.xlsx   
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    112
${cols}    16


*** Test Cases ***
TC06: 06_Data_RegisterSchool
    [Documentation]    Test_06_Data_EditProfile
    [Tags]    Edit_Profile
    Go To Academic_Services    ${datatable}
    Go To Login Page
    Login As Member
    
    FOR    ${i}    IN RANGE    2    ${rows}+1    
        Run EditFrofile    ${i}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document
    
