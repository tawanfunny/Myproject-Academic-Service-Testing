*** Settings ***
Library    SeleniumLibrary
Resource    TC14_ReviewAcademicServices.robot

*** Keywords ***
Clear Review Data In DB
    [Arguments]    ${i}
    ${UNStudent}=    Read Excel Cell    ${i}    2
    ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent
    Log To Console    Trying to delete proposal with studentId: ${UNStudent}
    ${query}=    Set Variable    DELETE FROM `db_academic_services`.`review` WHERE studentId = '${UNStudent}';
    Execute Sql String    ${query}
    # ${query}=    Set Variable    UPDATE review SET activityImg = NULL WHERE studentId = '${student_id}';
    # Execute Sql String    ${query}

Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC14-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.1

Run ReviewAcademicServices
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    11
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Go To Login Page
    ...    AND    Login As Student    ${row}
    ...    AND    Go To Review Page
    ...    AND    Upload Image And Review    ${row}
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Check Uploaded Image Extension In DB    ${row}
    ...    AND    Validate And Write Result    ${row}
 
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}

Go To Login Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับนักศึกษา')] 

Login As Student
    [Arguments]    ${i}
    ${UNStudent}    Read Excel Cell    ${i}    2
    ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent
    Input Text    css:#stuname    ${UNStudent}

    ${PWDStudent}    Read Excel Cell    ${i}    3
    ${PWDStudent}=    Evaluate    '' if $PWDStudent in ['None', '', None] else $PWDStudent
    Input Text    css:#stupwd   ${PWDStudent}

    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT

Go To Review Page
    Wait Until Element Is Visible    //body/div[1]/div[1]/div[4]/a[1]

    Click Element    //body/div[1]/div[1]/div[4]/a[1]
    Run Keyword And Ignore Error    Click Element    css:.button-link.button-view

Upload Image And Review
    [Arguments]    ${i}
    ${ImageFile}    Read Excel Cell    ${i}    4
    ${ImageFile}=    Evaluate    '' if $ImageFile in ['None', '', None] else $ImageFile
    ${ImageFile}    Set Variable    ${upload_path}${ImageFile}
        
    ${is_exist}=    Run Keyword And Return Status    File Should Exist    ${ImageFile}
    Run Keyword If    ${is_exist}    Choose File    css:#activityImg    ${ImageFile}
    
    ${reviewDetail}    Read Excel Cell    ${i}    5
    ${reviewDetail}=    Evaluate    '' if $reviewDetail in ['None', '', None] else $reviewDetail
    Input Text    css:#reviewDetail   ${reviewDetail}
        
    Click Element    //button[contains(text(),'อัปโหลด')]

Handle Submission Result
        [Arguments]    ${i}
        ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
        Log To Console    Alert Status: ${alert_result[0]}
        Log To Console    Alert Text: ${alert_result[1]}

        Set Test Variable    ${alert_result}
        
        IF    '${alert_result[0]}' == 'PASS'
            ${ActualMessage}=    Set Variable    ${alert_result[1]}  
            Click Element   //a[contains(text(),'ออกจากระบบ')]
        ELSE
            ${ActualMessage}=    Set Variable    AlertNotFound
            Sleep    2
            Capture Page Screenshot    Project_Test_AcademicService/TC14_ReviewAcademicServices/Screenshots_AlertNotFound/${i}_${ActualMessage}.png
            Go To    ${URL} 
        END

        Set Test Variable    ${ActualMessage}
        Sleep    2

Check Uploaded Image Extension In DB
    [Arguments]    ${i}
    ${UNStudent}=    Read Excel Cell    ${i}    2
    ${UNStudent}=    Evaluate    re.sub(r'\s+', '', str($UNStudent))    re
    ${UNStudent}=    Evaluate    str($UNStudent).strip()
    ${UNStudent}=    Evaluate    '' if $UNStudent in ['None', '', None] else $UNStudent.strip()

    Sleep    3
    ${query}=    Set Variable    SELECT activityImg FROM review WHERE TRIM(studentId)='${UNStudent}'
    Log To Console    Executing query: ${query}
    Log To Console    >> Excel StudentId Raw: "${UNStudent}"

    Sleep    3

    ${result}=    Query    ${query}
    Log To Console    DB query result: ${result}

    ${dbcheck}=    Run Keyword And Return Status    Should Not Be Empty    ${result}

    Run Keyword Unless    ${dbcheck}    Write Excel Cell    ${i}    9    NOT FOUND

    IF    ${dbcheck}
        ${img_url}=    Set Variable    ${result[0][0]}
        Run Keyword If    '${img_url}' == 'None' or '${img_url}' == ''    Write Excel Cell    ${i}    9    NOT FOUND
        ...    ELSE
        ...    Run Keyword    
        ...    Check Image Extension Valid    ${img_url}    ${i}

        # # แบ่ง string โดยใช้จุด (.) เพื่อเอานามสกุล
        # ${parts}=    Split String    ${img_url}    .
        # ${img_ext}=    Set Variable    ${parts}[-1]
        # ${img_ext}=    Convert To Lower Case    ${img_ext}

        # Log To Console    Image extension from DB: ${img_ext}

        # ${is_valid}=    Evaluate    '${img_ext}' in ['jpg','jpeg','png']

        # IF    ${is_valid}
        #     Write Excel Cell    ${i}    9    TRUE
        # ELSE
        #     Write Excel Cell    ${i}    9    FALSE
        # END
    ELSE
        Write Excel Cell    ${i}    9    NOT FOUND
    END

Check Image Extension Valid
    [Arguments]    ${img_url}    ${i}
    ${parts}=    Split String    ${img_url}    .
    ${img_ext}=    Set Variable    ${parts}[-1]
    ${img_ext}=    Convert To Lower Case    ${img_ext}
    Log To Console    Image extension from DB: ${img_ext}

    ${is_valid}=    Evaluate    '${img_ext}' in ['jpg','jpeg','png']
    IF    ${is_valid}
        Write Excel Cell    ${i}    9    TRUE
    ELSE
        Write Excel Cell    ${i}    9    FALSE
    END
    


Validate And Write Result
        [Arguments]    ${i}
        ${ExpectedResult}    Read Excel Cell    ${i}    6
        Log To Console    Expected Result: ${ExpectedResult}
        Log To Console    Actual Message: ${ActualMessage}

        Write Excel Cell    ${i}    8    ${ActualMessage}
        ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
        IF    ${compare_result}
            Write Excel Cell    ${i}    10    PASS
            Capture Page Screenshot    Project_Test_AcademicService/TC14_ReviewAcademicServices/Screenshots_Pass/${i}_${ActualMessage}.png
        ELSE
            Write Excel Cell    ${i}    10    FAIL
            Capture Page Screenshot    Project_Test_AcademicService/TC14_ReviewAcademicServices/Screenshots_Fail/${i}_${ActualMessage}.png
        END
    
        Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}


Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    13    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    13    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}
