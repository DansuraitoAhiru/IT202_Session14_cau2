USE RikkeiClinicDB;

-- code gốc
DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_new_bed_id INT
)
BEGIN
    START TRANSACTION;

    -- Giải phóng giường cũ
    UPDATE Beds
    SET patient_id = NULL
    WHERE patient_id = p_patient_id;

    -- Gán giường mới
    UPDATE Beds
    SET patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;

    COMMIT;
END //

DELIMITER ;

-- Phần A
-- test lỗi
call TransferBed(1, 102);
select * from Beds;

-- Việc để một bệnh nhân lơ lửng không có giường như trên cũng vi phạm đặc tính Atomicity (hoặc thực hiện hết hoặc ko thực hiện j cả)
-- nghĩa là vì đặc tính này, hệ thống bị gián đoạn giữa chừng khiến dữ liệu ko nhất quán giường cũ đã bị bỏ trống, nhưng giường mới chưa nhận bệnh nhân
-- nên tốt nhất là phải thêm rollback để khi kết nối bị ngắt vẫn có thể khôi phục trở lại trạng thái ban đầu

-- Phần B: sửa
drop procedure TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_new_bed_id INT
)
BEGIN
    START TRANSACTION;

    -- Giải phóng giường cũ
    UPDATE Beds
    SET patient_id = NULL
    WHERE patient_id = p_patient_id;

	ROLLBACK;
    
    -- Gán giường mới
    UPDATE Beds
    SET patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;

    COMMIT;
END //

DELIMITER ;