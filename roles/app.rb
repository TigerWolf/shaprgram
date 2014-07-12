name 'App'
description 'The actual app'
run_list 'recipe[ruby_2]', 'role[db_client]', 'role[db]'

