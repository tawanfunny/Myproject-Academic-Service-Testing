*** Settings ***
Library    SeleniumLibrary
Resource    TC16_Database_LecturerLogin.robot

*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2
Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC16-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
  

Run Database_LoginLecturer
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    9
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}

    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Setup Speed
    ...    AND    Go To Login Page
    ...    AND   Fill Lecturer Login Form    ${row}
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Validate Database For Login    ${row}    ${lecturerUsername}    ${lecturerPassword}
    ...    AND    Compare Result And Write Status    ${row}

 
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}

Go To Login Page
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับอาจารย์')]

Fill Lecturer Login Form
    [Arguments]    ${i}
    ${lecturerUsername}    Read Excel Cell    ${i}    2
    ${lecturerUsername}=    Evaluate    '' if $lecturerUsername in ['None', '', None] else $lecturerUsername
    Input Text    //input[@id='lecname']    ${lecturerUsername}
    set Test Variable    ${lecturerUsername}

    ${lecturerPassword}    Read Excel Cell    ${i}    3
    ${lecturerPassword}=    Evaluate    '' if $lecturerPassword in ['None', '', None] else $lecturerPassword
    Input Text    //input[@id='lecpwd']   ${lecturerPassword}
    set Test Variable    ${lecturerPassword}

    Click Button    //body/form[1]/input[3]

Handle Submission Result
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    4
    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT

    Log To Console    Alert Status: ${alert_result[0]}
    Log To Console    Alert Text: ${alert_result[1]}

    Set Test Variable    ${alert_result}
    IF    '${alert_result[0]}' == 'PASS'
        ${ActualMessage}=    Set Variable    ${alert_result[1]}
        Run Keyword And Ignore Error    Click Element    //a[contains(text(),'ออกจากระบบ')]
    ELSE
        ${ActualMessage}=    Set Variable    Alert not found
        Capture Page Screenshot    TC16_LecturerLogin/Screenshots_Database_AlertNotFound/${i}_AlertNotFound.png
        Sleep    2
        Run Keyword And Ignore Error    Click Element    css:a.back-home-link:nth-child(8)

    END
    
    Run Keyword And Ignore Error    Go To    ${URL}
    Set Test Variable    ${ActualMessage}
    Sleep    2

Validate Database For Login
    [Arguments]    ${i}    ${lecturerUsername}    ${lecturerPassword}
    ${username_result}=    Query    SELECT lecturerUsername FROM lecturer WHERE lecturerUsername='${lecturerUsername}'
    ${has_username}=    Run Keyword And Return Status    Should Not Be Empty    ${username_result}
    Run Keyword If    ${has_username}    Should Be Equal As Strings    ${username_result[0][0]}    ${lecturerUsername}

    ${password_result}=    Query    SELECT lecturerPassword FROM lecturer WHERE lecturerPassword='${lecturerPassword}'
    ${has_password}=    Run Keyword And Return Status    Should Not Be Empty    ${password_result}
    Run Keyword If    ${has_password}    Should Be Equal As Strings    ${password_result[0][0]}    ${lecturerPassword}

    ${found_condition}=    Evaluate    ${has_username} and ${has_password}
    Run Keyword If    '${has_username}' == 'True'
    ...    Log To Console    Username: ${lecturerUsername} => พบในฐานข้อมูล
    Run Keyword If    '${has_username}' == 'False'
    ...    Log To Console    Username: ${lecturerUsername} => ไม่พบในฐานข้อมูล
    Run Keyword If    '${has_password}' == 'True'
    ...    Log To Console    Password: ${lecturerPassword} => พบในฐานข้อมูล
    Run Keyword If    '${has_password}' == 'False'
    ...    Log To Console    Password: ${lecturerPassword} => ไม่พบในฐานข้อมูล

    Run Keyword If    ${found_condition}
    ...    Write Excel Cell    ${i}    7    FOUND
    Run Keyword If    not ${found_condition}
    ...    Write Excel Cell    ${i}    7    NOT FOUND

Compare Result And Write Status
    [Arguments]    ${i}   
    ${ExpectedResult}=    Read Excel Cell    ${i}    4

    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}
    
    Write Excel Cell    ${i}    6    ${ActualMessage}

    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${i}    8    PASS
        Capture Page Screenshot    TC16_LecturerLogin/Screenshots_Database_Pass/${i}_${ActualMessage}.png
    ELSE
        Write Excel Cell    ${i}    8    FAIL
        Capture Page Screenshot    TC16_LecturerLogin/Screenshots_Database_Fail/${i}_${ActualMessage}.png
    END

    Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}


Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    11    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    11    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}

