*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC13_EditUploadCompleteReport.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC13_EditUploadCompleteReport/13_Data_EditUploadCompletereport.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    18
${cols}    13
${upload_path}    ${CURDIR}/EditPDF/

*** Test Cases ***
TC13: 13_Data_EditUploadCompleteReport
    [Documentation]    Test_13_Data_EditUploadCompleteReport
    [Tags]    EditUploadCompleteReport
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        ${UNStudent}=    Read Excel Cell    ${i}    2
        ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent

        # 1) เคลียร์ report data ก่อนทุกครั้ง
        Clear Report Data In DB    ${UNStudent}
        Run EditUploadCompleteReport   ${i}    
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document