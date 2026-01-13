create database thuchanh_ss12;
use thuchanh_ss12;

create table Users(
	user_id int auto_increment primary key,
    username varchar(50) not null unique,
    password varchar(255) not null,
    email varchar(100) not null unique,
    created_at datetime default (current_timestamp()),
    status enum('Active', 'Inactive') default 'Active'
);

create table Posts(
	post_id int auto_increment primary key,
    user_id int not null,
    content text not null,
    created_at datetime default (current_timestamp()),
    foreign key (user_id) references Users(user_id)
);

create table Comments(
	comment_id int auto_increment primary key,
    post_id int not null,
    user_id int not null,
    content text not null,
    created_at datetime default (current_timestamp()),
    foreign key (post_id) references Posts(post_id),
    foreign key (user_id) references Users(user_id)
);

create table Friends(
	user_id int not null,
    friend_id int not null,
    status varchar(20) check (status in ('pending','accepted')),
    foreign key (user_id) references Users(user_id),
    foreign key (friend_id) references Users(user_id)
);

create table Likes(
	user_id int not null,
    post_id int not null,
    foreign key (user_id) references Users(user_id),
    foreign key (post_id) references Posts(post_id)
);

insert into Users (username, password, email, status) values
('alice', 'pass1', 'alice@mail.com', 'Active'),
('bob', 'pass2', 'bob@mail.com', 'Active'),
('charlie', 'pass3', 'charlie@mail.com', 'Active'),
('david', 'pass4', 'david@mail.com', 'Active'),
('emma', 'pass5', 'emma@mail.com', 'Active'),
('frank', 'pass6', 'frank@mail.com', 'Active'),
('grace', 'pass7', 'grace@mail.com', 'Inactive'),
('henry', 'pass8', 'henry@mail.com', 'Active'),
('irene', 'pass9', 'irene@mail.com', 'Active'),
('jack', 'pass10', 'jack@mail.com', 'Active'),
('kate', 'pass11', 'kate@mail.com', 'Inactive'),
('leo', 'pass12', 'leo@mail.com', 'Active'),
('mia', 'pass13', 'mia@mail.com', 'Active'),
('nick', 'pass14', 'nick@mail.com', 'Active'),
('olivia', 'pass15', 'olivia@mail.com', 'Active');

insert into Posts (user_id, content) values
(1, 'Hello world!'),
(1, 'My second post'),
(2, 'Good morning'),
(3, 'Learning MySQL'),
(3, 'Foreign keys are fun'),
(4, 'Today is a good day'),
(5, 'I love coding'),
(6, 'Backend development'),
(7, 'Inactive user post'),
(8, 'Database design'),
(9, 'REST API'),
(10, 'Social network project'),
(11, 'Inactive thoughts'),
(12, 'Coding at night'),
(13, 'Debugging life'),
(8, 'Indexes are important');

insert into Comments (post_id, user_id, content) values
(1, 2, 'Nice post'),
(1, 3, 'Welcome'),
(2, 4, 'Interesting'),
(3, 1, 'Good luck'),
(4, 2, 'Helpful'),
(5, 6, 'Agreed'),
(6, 5, 'So true'),
(7, 8, 'Inactive but ok'),
(8, 9, 'Great'),
(9, 10, 'Useful info'),
(10, 11, 'Nice'),
(11, 12, 'Deep'),
(12, 13, 'Cool'),
(13, 1, 'Relatable'),
(14, 3, 'Very important');

insert into Friends (user_id, friend_id, status) values
(1, 2, 'accepted'),
(1, 3, 'accepted'),
(2, 3, 'pending'),
(2, 4, 'accepted'),
(3, 5, 'accepted'),
(4, 6, 'pending'),
(5, 6, 'accepted'),
(6, 7, 'accepted'),
(7, 8, 'pending'),
(8, 9, 'accepted'),
(9, 10, 'accepted'),
(10, 11, 'pending'),
(11, 12, 'accepted'),
(12, 13, 'accepted'),
(3, 8, 'pending');

insert into Likes (user_id, post_id) values
(2, 1),
(3, 1),
(4, 2),
(1, 3),
(5, 3),
(6, 4),
(7, 5),
(8, 6),
(9, 7),
(10, 8),
(11, 9),
(12, 10),
(13, 11),
(1, 12),
(3, 13);

-- Bài 1  Quản lý người dùng
select * from Users;

-- Bài 2
-- Chức năng mô phỏng: Trang hồ sơ công khai
create view vw_public_users as
select user_id, username, created_at from Users;

select * from vw_public_users;
-- So sánh với SELECT trực tiếp từ bảng Users.
-- View chỉ hiển thị user_id, username, created_at, ẩn trường password và email

-- Giải thích:
-- Lợi ích bảo mật của View.
-- View chỉ cho phép hiển thị ra những trường được khai báo -> có thể ẩn mật khẩu và những cột thông tin cần bảo mật

-- Bài 3. Tối ưu tìm kiếm người dùng bằng INDEX
create index idx_username on Users(username);

select * from Users where username = 'bob';

-- So sánh:
-- Truy vấn có Index
-- Truy vấn không Index (mô tả lý thuyết).
-- Truy vấn có index nhanh hơn truy vấn không index

-- Bài 4. Quản lý bài viết bằng Stored Procedure
delimiter //

create procedure sp_create_post(
in p_user_id int,
in p_content text
)
begin
if p_user_id in (select user_id from Users) 
then
insert into Posts(user_id, content) values (p_user_id, p_content);
end if;
end //

delimiter ;

call sp_create_post(1, 'Bài viết mới của user 1');

-- Bài 5. Hiển thị News Feed bằng VIEW
create view vw_recent_posts as
select * from Posts 
where created_at >= now() - interval 7 day;
 
select * from vw_recent_posts;

-- Bài 6. Tối ưu truy vấn bài viết
create index idx_user_id on Posts(user_id);
create index idx_id_time on Posts(user_id, created_at);

select * from Posts 
where user_id = 1 
order by created_at 
desc;

-- Phân tích: Vai trò của Composite Index.
-- Tạo index cho cả 2 cột để truy xuất nhanh hơn

-- Bài 7. Thống kê hoạt động bằng Stored Procedure
delimiter //

create procedure sp_count_posts(
in p_user_id int,
out p_total int
)
begin
select count(*) 
into p_total
from Posts 
where user_id = p_user_id;
end //

delimiter ;

set @total_posts = 0;
call sp_count_posts(1, @total_posts);
select @total_posts;

-- Bài 8. Kiểm soát dữ liệu bằng View WITH CHECK OPTION
create view vw_active_users as
select * from Users 
where status = 'Active'
with check option;
-- Insert thành công
insert into vw_active_users(user_id, username, password, email, created_at, status) values 
(16, 'jane', 'password16', 'jane@gmail.com', current_timestamp(), 'Active');
-- Insert thất bại 
insert into vw_active_users(user_id, username, password, email, created_at, status) values 
(17, 'christ', 'password17', 'christ@gmail.com', current_timestamp(), 'Inactive');

-- Bài 9. Quản lý kết bạn bằng Stored Procedure

delimiter //

create procedure sp_add_friend(
p_user_id int,
p_friend_id int
)
begin
if p_user_id <> p_friend_id
then insert into Friends(user_id,friend_id, status) values 
(p_user_id, p_friend_id, 'accepted');
end if;
end //

delimiter ;

-- Bài 10. Gợi ý bạn bè bằng Procedure nâng cao

-- Bài 11. Thống kê tương tác nâng cao

select p.post_id, p.user_id, p.content, count(l.user_id) as total_likes from Posts p
join Likes l on p.post_id = l.post_id
group by p.post_id
order by total_likes desc
limit 5;

create view vw_top_posts as 
select p.post_id, p.user_id, p.content, count(l.user_id) as total_likes from Posts p
join Likes l on p.post_id = l.post_id
group by p.post_id
order by total_likes desc
limit 5;

create index idx_likes_post_id on
Likes(post_id);

-- BÀI 12. QUẢN LÝ BÌNH LUẬN
delimiter //

create procedure sp_add_comment(
p_user_id int,
p_post_id int,
p_content text,
out noti text
)
begin
declare v_user_count int;
declare v_post_count int;

select count(*) 
into v_user_count 
from Users 
where user_id = p_user_id;

select count(*) 
into v_post_count 
from Posts  
where post_id = p_post_id;

if v_user_count = 0 then
set noti = 'Người dùng không tồn tại';
elseif v_post_count = 0 then
set noti = 'Bài viết không tồn tại';
else insert into Comments(user_id, post_id, content) values
(p_user_id, p_post_id, p_content);
set noti = 'Thêm bình luận thành công';
end if;
end //

delimiter ;
set @noti = '';
call sp_add_comment(1, 2, 'Hài quá', @noti);
select @noti as result;

-- BÀI 13. QUẢN LÝ LƯỢT THÍCH

delimiter //
create procedure sp_like_post(
p_user_id int,
p_post_id int
)
begin
declare v_like_count int;
select count(*) into v_like_count 
from Likes where user_id = p_user_id and post_id = p_post_id;

if v_like_count = 0 then
insert into Likes(user_id, post_id) values (p_user_id, p_post_id);
end if;
end //

delimiter ;

call sp_like_post(1,2);

create view vw_post_likes as
select post_id, count(user_id) as total_likes
from Likes
group by post_id;

select * from vw_post_likes;

-- Bài 14. TÌM KIẾM NGƯỜI DÙNG & BÀI VIẾT
delimiter //

create procedure sp_search_social(
p_option int,
p_keyword varchar(100),
out noti varchar(200)
)
begin
if p_option = 1 then 
select * from Users where username like concat('%',p_keyword, '%');
elseif p_option = 2 then
select * from Posts where content like concat('%',p_keyword, '%');
else set noti = 'Lựa chọn không hợp lệ';
end if;
end //
delimiter ;

call sp_search_social(1, 'an', @noti);
call sp_search_social(2, 'database', @noti);