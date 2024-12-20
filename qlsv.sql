-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th12 20, 2024 lúc 05:07 AM
-- Phiên bản máy phục vụ: 10.4.28-MariaDB
-- Phiên bản PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `qlsv`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddStudentToCourse` (IN `_course_code` VARCHAR(50), IN `_student_code` VARCHAR(50))   BEGIN
	insert into course_has_student(c_h_s_code, course_code, student_code) values (concat(_course_code, '_', _student_code),_course_code, _student_code);
    select 'SUCCESS' as result;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckLogin` (IN `_username` VARCHAR(50), IN `_password` VARCHAR(50))   BEGIN
	select count(*), username, type into @cnt, @username, @type from user where username  = _username and password  = _password GROUP BY username;
    if @cnt > 0 then
		select 'SUCCESS' as result, @username as user_username, @type as user_type;
	else
		select 'FAILURE' as result;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateCourse` (IN `_time` VARCHAR(50), IN `_room` VARCHAR(50), IN `_day` VARCHAR(50), IN `_teacher_code` VARCHAR(50), IN `_subject_code` VARCHAR(50), IN `_group` VARCHAR(50), IN `_start_time` VARCHAR(50), IN `_duration_time` VARCHAR(50))   BEGIN
	insert into course(`code`, `time`, `room`, `day_of_week`, `teacher_code`, `subject_code`, `group`, `start_time`, `duration_time`)
    values (UPPER(concat(_subject_code, '_', _group, '_', _time)), UPPER(_time), UPPER(_room), UPPER(_day), UPPER(_teacher_code), UPPER(_subject_code), _group, _start_time, _duration_time);
    select 'SUCCESS' as result;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateSubject` (IN `_code` VARCHAR(50), IN `_name` VARCHAR(50), IN `_num_credit` INT, IN `_major` VARCHAR(50))   begin
	select count(*) into @cnt
	from subject
	where code = _code;
	if @cnt = 0 then
		insert into subject(code, name, num_credit, major)
		values (UPPER(_code), _name, _num_credit, _major);
		select 'SUCCESS' as result;
	else
		select 'FAILURE! Ma mon hoc da ton tai' as result;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateUser` (IN `_name` VARCHAR(50), IN `_username` VARCHAR(50), IN `_type` VARCHAR(50), IN `_dob` VARCHAR(50), IN `_pob` VARCHAR(50), IN `_major` VARCHAR(50))   BEGIN
	select count(*) into @cnt from user where username = _username;
    if @cnt > 0 then
		select 'FAILURE' as result;
	else
		insert into user set name = _name, username = UPPER(_username), password = _dob, type = UPPER(_type), dob = _dob, pob = _pob;
        update student set major = _major where code = UPPER(_username);
		select 'SUCCESS' as result;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteStudent` (IN `_student_code` VARCHAR(50))   begin

	select count(*) into @cnt from student where code = _student_code;

	if @cnt > 0 then

		delete from user where username = _student_code;

		select 'SUCCESS, deleted!' as result;

	else

		select 'FAILURE, no student match infos provided' as result;

	end if;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteSubject` (IN `_code` VARCHAR(50))   begin

	select count(*) into @cnt

	from subject

	where code = _code;

	

	if @cnt > 0 then

		delete

		from subject

		where code = _code;

		select 'SUCCESS, deleted!' as result;

	else

		select 'FAILURE, trong database khong co subject nao khop voi code nhan duoc' as result;

	end if;

	

	

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadAllCourses` ()   BEGIN
	select c.code, s.name, c.group, c.room, c.start_time, c.duration_time, c.day_of_week
    from course c inner join subject s on c.subject_code = s.code;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadAllSubjects` ()   begin

		select code, name, num_credit, major

		from subject

		order by name desc;

	end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadResults` (IN `_student_code` VARCHAR(50))   begin

	select chs.c_h_s_code as code, s.name as name, r.chuyencan as chuyencan, r.giuaky as giuaky, r.baitap as baitap, r.cuoiky as cuoiky, r.`status` as `status`
    from course_has_student chs inner join course c on chs.course_code = c.code inner join subject s on c.subject_code = s.code inner join result r on chs.c_h_s_code = r.c_h_s_code
    where chs.student_code = _student_code;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadStudents` (IN `n` INT)   begin

	select s.code, u.name, u.dob, u.pob, s.major

	from student s inner join user u on s.code = u.username
    where u.type = 'STUDENT'

	order by s.id desc

	limit n;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadStudentsByKeyword` (IN `_keyword` VARCHAR(50))   begin

	select concat(u.name, ' (', s.code, ')') as result

	from student s inner join user u on s.code = u.username

	where concat(s.code, u.name, u.dob, u.pob, s.major) like concat('%', _keyword, '%');

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadStudentsFullInfoByKeyword` (IN `keyword` VARCHAR(50))   BEGIN
	select u.username as code, u.name as name, u.dob as dob, u.pob as pob, s.major as major
    from user u inner join student s on u.username = s.code
    where concat(u.username, u.name) like concat('%', keyword, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadSubjectNameByCode` (IN `_code` VARCHAR(50))   BEGIN
	select name into @name from subject where code = _code;
    if FOUND_ROWS() > 0 then
		select @name as result;
	else
		select 'NOT_FOUND' as result;
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadSubjectsByKeyword` (IN `_keyword` VARCHAR(50))   begin

	select code, name, num_credit, major

	from subject

	where concat(code, name, num_credit, major) like concat('%', _keyword, '%');

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadTeachersByKeyword` (IN `keyword` VARCHAR(50))   BEGIN
	select concat(u.name, ' (', t.code, ')') as result
    from teacher t inner join user u on t.code = u.username
    where u.name like concat('%', keyword, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ModifyStudent` (IN `_student_code` VARCHAR(50), IN `_student_name` VARCHAR(50), IN `_student_dob` VARCHAR(50), IN `_student_pob` VARCHAR(50), IN `_student_major` VARCHAR(50))   begin
	select count(*) into @cnt from student where code = _student_code;
	if @cnt > 0 then
		UPDATE user
		set name = _student_name, dob = _student_dob, pob = _student_pob
		where username = _student_code;
        update student set major = _student_major where code = _student_code;
		select 'SUCCESS' as result;
	else
		select 'FAILURE' as result;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ModifyStudentResult` (IN `_result_code` VARCHAR(50), IN `_chuyencan` VARCHAR(50), IN `_giuaky` VARCHAR(50), IN `_baitap` VARCHAR(50), IN `_cuoiky` VARCHAR(50), IN `_status` VARCHAR(50))   BEGIN
	update result
    set chuyencan = _chuyencan,
		giuaky = _giuaky,
        baitap = _baitap,
        cuoiky = _cuoiky,
        status = _status
	where c_h_s_code = _result_code;
    select 'SUCCESS' as result;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ModifySubject` (IN `_code` VARCHAR(50), IN `_name` VARCHAR(50), IN `_num_credit` INT, IN `_major` VARCHAR(50))   begin

		update subject

		set name = _name, num_credit = _num_credit, major = _major

		where code = _code;

		select 'SUCCESS' as result;

	end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `course`
--

CREATE TABLE `course` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL DEFAULT '0',
  `time` varchar(50) DEFAULT NULL,
  `room` varchar(50) DEFAULT NULL,
  `teacher_code` varchar(50) NOT NULL,
  `subject_code` varchar(50) NOT NULL,
  `group` varchar(5) DEFAULT NULL,
  `start_time` varchar(5) DEFAULT NULL,
  `duration_time` varchar(5) DEFAULT NULL,
  `day_of_week` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `course`
--

INSERT INTO `course` (`id`, `code`, `time`, `room`, `teacher_code`, `subject_code`, `group`, `start_time`, `duration_time`, `day_of_week`) VALUES
(4, 'CNTT001', '2020', '201 tòa G', 'TEA02', 'CNTT001', '1', '2', '2', 'TUESDAY'),
(7, 'CNTT002', '2020', '302 Tòa F', 'TEA02', 'CNTT002', '2', '3', '2', 'FRIDAY'),
(6, 'CNTT003', '2020', '501 tòa E', 'TEA03', 'CNTT003', '1', '1', '2', 'THURSDAY'),
(3, 'CNTT005', '2020', '401 tòa D', 'TEA01', 'CNTT005', '1', '1', '2', 'MONDAY');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `course_has_student`
--

CREATE TABLE `course_has_student` (
  `id` int(11) NOT NULL,
  `c_h_s_code` varchar(50) NOT NULL,
  `course_code` varchar(50) NOT NULL,
  `student_code` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `course_has_student`
--

INSERT INTO `course_has_student` (`id`, `c_h_s_code`, `course_code`, `student_code`) VALUES
(4, 'CNTT001_2020_SV01', 'CNTT001', 'SV01'),
(3, 'CNTT001_2020_SV02', 'CNTT001', 'SV02'),
(8, 'CNTT001_2020_SV03', 'CNTT001', 'SV03'),
(10, 'CNTT001_SV04', 'CNTT001', 'SV04'),
(7, 'CNTT002_2020_SV03', 'CNTT002', 'SV03'),
(5, 'CNTT003_2020_SV01', 'CNTT003', 'SV01'),
(6, 'CNTT005_2020_SV01', 'CNTT005', 'SV01');

--
-- Bẫy `course_has_student`
--
DELIMITER $$
CREATE TRIGGER `course_has_student_AFTER_INSERT` AFTER INSERT ON `course_has_student` FOR EACH ROW BEGIN
	insert into result(c_h_s_code)
    values(new.c_h_s_code);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `employee`
--

CREATE TABLE `employee` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `employee`
--

INSERT INTO `employee` (`id`, `code`) VALUES
(1, 'admin');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `result`
--

CREATE TABLE `result` (
  `id` int(11) NOT NULL,
  `chuyencan` varchar(50) NOT NULL DEFAULT '0',
  `giuaky` varchar(50) NOT NULL DEFAULT '0',
  `baitap` varchar(50) NOT NULL DEFAULT '0',
  `cuoiky` varchar(50) NOT NULL DEFAULT '0',
  `status` varchar(50) DEFAULT NULL,
  `c_h_s_code` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `result`
--

INSERT INTO `result` (`id`, `chuyencan`, `giuaky`, `baitap`, `cuoiky`, `status`, `c_h_s_code`) VALUES
(1, '10', '3', '2', '7', 'STUDIED', 'CNTT001_2020_SV02'),
(2, '10', '9', '10', '5', 'STUDYING', 'CNTT001_2020_SV01'),
(3, '9', '8', '7', '6', 'STUDIED', 'CNTT003_2020_SV01'),
(4, '8', '7', '6', '5', 'STUDIED', 'CNTT005_2020_SV01'),
(5, '7', '8', '9', '10', 'STUDIED', 'CNTT002_2020_SV03'),
(6, '2', '3', '4', '5', 'STUDIED', 'CNTT001_2020_SV03'),
(7, '0', '0', '0', '0', NULL, 'CNTT001_SV04');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `student`
--

CREATE TABLE `student` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `major` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `student`
--

INSERT INTO `student` (`id`, `code`, `major`) VALUES
(40, 'SV01', 'Công nghệ Thông tin'),
(39, 'SV02', 'Công nghệ Thông tin'),
(38, 'SV03', 'Công nghệ Thông tin'),
(41, 'SV04', 'Công nghệ Thông tin');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `subject`
--

CREATE TABLE `subject` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `num_credit` varchar(50) NOT NULL,
  `major` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `subject`
--

INSERT INTO `subject` (`id`, `code`, `name`, `num_credit`, `major`) VALUES
(1, 'CNTT001', 'Lập trình C', '2', 'CNTT'),
(2, 'CNTT002', 'Lập trình C++', '3', 'CNTT'),
(3, 'CNTT003', 'Cơ sở dữ liệu', '3', 'CNTT'),
(4, 'CNTT004', 'Các hệ thống phân tán', '3', 'CNTT'),
(5, 'CNTT005', 'Trí tuệ nhân tạo', '3', 'CNTT'),
(6, 'CNTT006', 'Lập trình nhúng', '3', 'CNTT');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `teacher`
--

CREATE TABLE `teacher` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `teacher`
--

INSERT INTO `teacher` (`id`, `code`) VALUES
(2, 'TEA03'),
(3, 'TEA02'),
(4, 'TEA01');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `dob` varchar(50) DEFAULT NULL,
  `pob` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `user`
--

INSERT INTO `user` (`id`, `name`, `username`, `password`, `type`, `dob`, `pob`) VALUES
(1, 'Trinhlee', 'admin', 'admin', 'EMPLOYEE', '?', '?'),
(5, 'Hà Thị B', 'SV01', '123456', 'STUDENT', '231200', 'Sài Gòn'),
(6, 'Trần Văn C', 'SV02', '123456', 'STUDENT', '250800', 'Quảng Nam'),
(7, 'Lã Văn A', 'SV03', '123456', 'STUDENT', '040500', 'Hà Nội'),
(56, 'aa', 'SV04', '231200', 'STUDENT', '231200', 'Sài Gòn'),
(4, 'Trung', 'TEA01', '123456', 'TEACHER', '??????', 'Đà Nẵng'),
(2, 'Trọng', 'TEA02', '123456', 'TEACHER', '??????', 'Đà Nẵng'),
(3, 'Trang', 'TEA03', '123456', 'TEACHER', '??????', 'Quảng Trị'),
(8, 'Trinh', 'TEA04', '123456', 'TEACHER', '??????', 'Hà tĩnh');

--
-- Bẫy `user`
--
DELIMITER $$
CREATE TRIGGER `user_AFTER_INSERT` AFTER INSERT ON `user` FOR EACH ROW BEGIN
	if new.type = 'STUDENT' then
		insert into student(code, major) values (new.username, 'default_major');
    elseif new.type = 'EMPLOYEE' then
		insert into employee(code) values (new.username);
    elseif new.type = 'TEACHER' then
		insert into teacher(code) values (new.username);
    end if;
END
$$
DELIMITER ;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`code`),
  ADD KEY `id` (`id`),
  ADD KEY `fk_course_teacher1_idx` (`teacher_code`),
  ADD KEY `fk_course_subject1_idx` (`subject_code`);

--
-- Chỉ mục cho bảng `course_has_student`
--
ALTER TABLE `course_has_student`
  ADD PRIMARY KEY (`c_h_s_code`),
  ADD UNIQUE KEY `id_UNIQUE` (`id`),
  ADD KEY `fk_course_has_student_student1_idx` (`student_code`),
  ADD KEY `fk_course_has_student_course1_idx` (`course_code`);

--
-- Chỉ mục cho bảng `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`code`),
  ADD KEY `id` (`id`);

--
-- Chỉ mục cho bảng `result`
--
ALTER TABLE `result`
  ADD PRIMARY KEY (`id`,`c_h_s_code`),
  ADD KEY `id` (`id`),
  ADD KEY `fk_result_course_has_student1_idx` (`c_h_s_code`);

--
-- Chỉ mục cho bảng `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`code`),
  ADD KEY `id` (`id`);

--
-- Chỉ mục cho bảng `subject`
--
ALTER TABLE `subject`
  ADD PRIMARY KEY (`code`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `id` (`id`);

--
-- Chỉ mục cho bảng `teacher`
--
ALTER TABLE `teacher`
  ADD PRIMARY KEY (`id`,`code`),
  ADD KEY `fk_teacher_user1` (`code`);

--
-- Chỉ mục cho bảng `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `id` (`id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `course`
--
ALTER TABLE `course`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `course_has_student`
--
ALTER TABLE `course_has_student`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `employee`
--
ALTER TABLE `employee`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `result`
--
ALTER TABLE `result`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT cho bảng `student`
--
ALTER TABLE `student`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT cho bảng `subject`
--
ALTER TABLE `subject`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `teacher`
--
ALTER TABLE `teacher`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `fk_course_subject1` FOREIGN KEY (`subject_code`) REFERENCES `subject` (`code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_course_teacher1` FOREIGN KEY (`teacher_code`) REFERENCES `teacher` (`code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `course_has_student`
--
ALTER TABLE `course_has_student`
  ADD CONSTRAINT `fk_course_has_student_course1` FOREIGN KEY (`course_code`) REFERENCES `course` (`code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_course_has_student_student1` FOREIGN KEY (`student_code`) REFERENCES `student` (`code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `fk_employee_user1` FOREIGN KEY (`code`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `result`
--
ALTER TABLE `result`
  ADD CONSTRAINT `fk_result_course_has_student1` FOREIGN KEY (`c_h_s_code`) REFERENCES `course_has_student` (`c_h_s_code`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `fk_student_user1` FOREIGN KEY (`code`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `teacher`
--
ALTER TABLE `teacher`
  ADD CONSTRAINT `fk_teacher_user1` FOREIGN KEY (`code`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
