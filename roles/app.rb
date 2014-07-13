name 'app'
description 'The actual app'
run_list 'recipe[ruby_2]', 'role[db]',  'recipe[postgresql::yum_pgdg_postgresql]'

