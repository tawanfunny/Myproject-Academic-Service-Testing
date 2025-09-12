*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC14_ReviewAcademicServices.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC14_ReviewAcademicServices/14_Data_ReviewAcademicServices.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    12345
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    29
${cols}    13
${upload_path}    ${CURDIR}/Images/

*** Test Cases ***
TC14: 14_Data_ReviewAcademicService
    [Documentation]    Test_14_Data_ReviewAcademicServices
    [Tags]    ReviewAcademicServices
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Clear Review Data In DB    ${i}
        Run ReviewAcademicServices   ${i}    
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document