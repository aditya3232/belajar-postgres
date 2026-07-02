-- hr -> nama user
-- superuser -> punya akses penuh seperti root, tapi tidak bisa create db (rolcreatedb ❌ || rolcanlogin ✅ || rolsuper ✅)
-- login -> boleh login ke database
-- passwordnya -> hr
create user hr with superuser login password 'hr';
