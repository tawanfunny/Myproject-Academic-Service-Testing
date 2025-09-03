*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC15_EditReviewAcademicServices.robot
Suite Setup    Connect to Database     ${DB_TYPE}    ${DB_NAME}    ${DB_USER}    
...    ${DB_PASS}    ${DB_HOST}    ${DB_PORT}
Suite Teardown    Disconnect from Database


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC15_EditReviewAcademicServices/15_Data_EditReviewAcademicServices.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${DB_TYPE}    pymysql
${DB_NAME}    db_academic_services
${DB_USER}    root
${DB_PASS}    1234
${DB_HOST}    127.0.0.1
${DB_PORT}    3307
${rows}    20
${cols}    13
${upload_path}    ${CURDIR}/Images/

*** Test Cases ***
TC15: 15_Data_EditReviewAcademicServices
    [Documentation]    Test_15_Data_EditReviewAcademicServices
    [Tags]    EditReviewAcademicServices
    Set Selenium Speed    2.5
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        ${UNStudent}=    Read Excel Cell    ${i}    2
        ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent
        # 1) เคลียร์ review data ก่อนทุกครั้ง
        Clear Review Data In DB    ${UNStudent}
        Run EditReviewAcademicServices   ${i}    
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document