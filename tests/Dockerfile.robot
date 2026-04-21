FROM python:3.10-slim
# อัปเดตและติดตั้ง Chromiumและตัว Driver
RUN apt-get update && apt-get install -y chromium chromium-driver
# กําหนดพื้นที่ทํางานภายใน Docker
WORKDIR /tests
# คัดลอกไฟล์ requirements และติดตั้ง
COPY requirements-test.txt .

RUN pip install --no-cache-dir -r requirements-test.txt
# กําหนดคําสั่งเริ่มต้น: สั่งรัน robot และเก็บ result ไว์ที่โฟลเดอร์ results
CMD ["robot", "-d", "results", "."]