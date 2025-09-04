*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Library    Collections
Resource    KeywordTC08_Data.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC08_LoginStudent/08_Data_LoginStudent.xlsx 
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    18
${cols}    8

*** Test Cases ***    
TC08: 08_Data_LoginStudent
    [Documentation]    Test_08_Data_LoginStudent
    [Tags]    Login_Data_Student
    Go To Academic_Services    ${datatable}

    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run Data_LoginStudent   ${i}
    END       
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document