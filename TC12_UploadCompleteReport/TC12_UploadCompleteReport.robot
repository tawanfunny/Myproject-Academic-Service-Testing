*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC12_UploadCompleteReport.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database

*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC12_UploadCompleteReport/12_Data_UploadCompleteReport.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome 
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    18   
${cols}    12
${upload_path}    ${CURDIR}/PDF/

*** Test Cases ***
TC12: 12_UploadCompleteReport
    [Documentation]    Test_12_Data_UploadCompleteReport
    [Tags]    UploadCompleteReport
    Set Selenium Speed    2.5
    
    Go To Academic_Services    ${datatable}
    
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Clear Report Data In DB    ${i}
        Run UploadCompleteReport    ${i}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document