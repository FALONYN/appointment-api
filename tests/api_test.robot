*** Settings ***
Library    RequestsLibrary
Library    Collections
*** Variables ***
# ใช้ชื่อ service 'api-server' (หรือชื่อที่ตั้งไว้ใน docker-compose) และใช้ port ภายในของ docker-compose 
# คือ 8000 แทนที่จะใช้ 3340 
${BASE_URL}    http://api-server:8000

*** Test Cases ***
Verify Get All Appointments Successfully
    [Documentation]    GET /appointments – ดึงข้อมูลนัดหมายทั้งหมด ต้องได้ Status 200
    Create Session    api_session    ${BASE_URL}
    ${response}=      GET On Session    api_session    /appointments
    Status Should Be  200    ${response}
    Log To Console    \nAppointments: ${response.json()}

Verify Create New Appointment
    [Documentation]    POST /appointments – สร้างนัดหมายใหม่ และตรวจสอบว่าบันทึกสำเร็จ
    Create Session    api_session    ${BASE_URL}

    ${payload}=    Create Dictionary
    ...    idCard=1234567890123
    ...    fullName=Robot Patient
    ...    phone=0999999999
    ...    gender=Male
    ...    dob=2000-01-01
    ...    address=Bangkok
    ...    maritalStatus=Single
    ...    appointmentDate=2026-05-01
    ...    appointmentTime=09:00

    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    api_session    /appointments
    ...    json=${payload}    headers=${headers}

    Status Should Be    200    ${response}
    ${body}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${body}
    Log To Console    \nCreated Appointment: ${body}


Verify Update Appointment
    [Documentation]    PUT /appointments/{id} – แก้ไขนัดหมาย (ใช้ record ที่สร้างใหม่)
    Create Session    api_session    ${BASE_URL}

    ${payload}=    Create Dictionary
    ...    idCard=9999999999999
    ...    fullName=Edit Robot Patient
    ...    phone=0888888888
    ...    gender=Male
    ...    dob=2000-01-01
    ...    address=Bangkok
    ...    maritalStatus=Single
    ...    appointmentDate=2026-05-02
    ...    appointmentTime=10:00

    ${headers}=    Create Dictionary    Content-Type=application/json
    ${create_resp}=    POST On Session    api_session    /appointments
    ...    json=${payload}    headers=${headers}

    Status Should Be    200    ${create_resp}
    ${created_id}=    Set Variable    ${create_resp.json()}[data][id]

    ${update_payload}=    Create Dictionary
    ...    idCard=9999999999999
    ...    fullName=Edit Robot Patient Updated
    ...    phone=0888888888
    ...    gender=Male
    ...    dob=2000-01-01
    ...    address=Bangkok
    ...    maritalStatus=Single
    ...    appointmentDate=2026-05-02
    ...    appointmentTime=11:00

    ${update_resp}=    PUT On Session    api_session    /appointments/${created_id}
    ...    json=${update_payload}    headers=${headers}

    Status Should Be    200    ${update_resp}
    Should Not Be Empty    ${update_resp.json()}
    Log To Console    \nUpdated Appointment: ${update_resp.json()}


Verify Delete Appointment
    [Documentation]    DELETE /appointments/{id} – ลบนัดหมาย

    ${payload}=    Create Dictionary
    ...    idCard=7777777777777
    ...    fullName=Delete Robot Patient
    ...    phone=0777777777
    ...    gender=Male
    ...    dob=2000-01-01
    ...    address=Bangkok
    ...    maritalStatus=Single
    ...    appointmentDate=2026-05-03
    ...    appointmentTime=14:00

    ${headers}=    Create Dictionary    Content-Type=application/json
    ${create_resp}=    POST On Session    api_session    /appointments
    ...    json=${payload}    headers=${headers}

    Status Should Be    200    ${create_resp}
    ${created_id}=    Set Variable    ${create_resp.json()}[data][id]

    # delete
    ${del_resp}=    DELETE On Session    api_session    /appointments/${created_id}

    Status Should Be    200    ${del_resp}
    Should Not Be Empty    ${del_resp.json()}
    Log To Console    \nDeleted Appointment ID: ${created_id}

# ─────────────────────────────────────────────
#  PATIENTS
# ─────────────────────────────────────────────

Verify Get All Patients Successfully
    [Documentation]    GET /patients – ดึงข้อมูลคนไข้ทั้งหมด ต้องได้ Status 200
    ${response}=    GET On Session    api_session    /patients
    Status Should Be    200    ${response}
    Log To Console    \nPatients: ${response.json()}

Verify Create New Patient
    [Documentation]    POST /patients – เพิ่มข้อมูลคนไข้ใหม่
    ${payload}=    Create Dictionary
    ...    hn_number=HN999
    ...    patient_name=Robot Tester
    ...    exam_date=2026-03-31
    ...    diagnosis=Automated Testing
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${response}=    POST On Session    api_session    /patients
    ...    json=${payload}    headers=${headers}
    Status Should Be    200    ${response}
    Log To Console    \nCreated Patient: ${response.json()}

Verify Update Patient
    [Documentation]    PUT /patients/{id} – แก้ไขข้อมูลคนไข้
    # สร้างคนไข้ก่อน
    ${payload}=    Create Dictionary
    ...    hn_number=HN888
    ...    patient_name=Edit Patient
    ...    exam_date=2026-04-01
    ...    diagnosis=Before Update
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${create_resp}=    POST On Session    api_session    /patients
    ...    json=${payload}    headers=${headers}
    Status Should Be    200    ${create_resp}
    ${created_id}=    Set Variable    ${create_resp.json()}[id]

    # แก้ไข
    ${update_payload}=    Create Dictionary
    ...    hn_number=HN888
    ...    patient_name=Edit Patient Updated
    ...    exam_date=2026-04-01
    ...    diagnosis=After Update
    ${update_resp}=    PUT On Session    api_session    /patients/${created_id}
    ...    json=${update_payload}    headers=${headers}
    Status Should Be    200    ${update_resp}
    Log To Console    \nUpdated Patient: ${update_resp.json()}

Verify Delete Patient
    [Documentation]    DELETE /patients/{id} – ลบข้อมูลคนไข้
    # สร้างคนไข้ก่อน
    ${payload}=    Create Dictionary
    ...    hn_number=HN777
    ...    patient_name=Delete Patient
    ...    exam_date=2026-04-02
    ...    diagnosis=To be deleted
    ${headers}=    Create Dictionary    Content-Type=application/json
    ${create_resp}=    POST On Session    api_session    /patients
    ...    json=${payload}    headers=${headers}
    Status Should Be    200    ${create_resp}
    ${created_id}=    Set Variable    ${create_resp.json()}[id]

    # ลบ
    ${del_resp}=    DELETE On Session    api_session    /patients/${created_id}
    Status Should Be    200    ${del_resp}
    Should Contain    str(${del_resp.json()})    deleted
    Log To Console    \nDeleted Patient ID: ${created_id}