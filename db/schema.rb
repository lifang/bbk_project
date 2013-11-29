# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131128134804) do

  create_table "abandon_tasks", :force => true do |t|
    t.integer  "task_id"
    t.integer  "types"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "abandon_tasks", ["task_id"], :name => "index_abandon_tasks_on_task_id"
  add_index "abandon_tasks", ["user_id"], :name => "index_abandon_tasks_on_user_id"

  create_table "accessories", :force => true do |t|
    t.string   "name"
    t.integer  "types"
    t.integer  "task_id"
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "longness"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "accessory_url"
  end

  add_index "accessories", ["task_id"], :name => "index_accessories_on_task_id"

  create_table "calculations", :force => true do |t|
    t.integer  "user_id"
    t.string   "month"
    t.string   "time"
    t.boolean  "is_pay"
    t.integer  "longness"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "calculations", ["user_id"], :name => "index_calculations_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "reciver_id"
    t.string   "content"
    t.integer  "accessory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["accessory_id"], :name => "index_messages_on_accessory_id"

  create_table "task_tags", :force => true do |t|
    t.string   "name"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.integer  "types"
    t.string   "origin_ppt_url"
    t.string   "origin_flash_url"
    t.integer  "ppt_doer"
    t.integer  "flash_doer"
    t.integer  "status"
    t.integer  "checker"
    t.string   "ppt_start_time"
    t.string   "flash_start_time"
    t.boolean  "is_calculate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_tag_id"
  end

  add_index "tasks", ["task_tag_id"], :name => "index_tasks_on_task_tag_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password"
    t.integer  "types"
    t.string   "phone"
    t.string   "address"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
