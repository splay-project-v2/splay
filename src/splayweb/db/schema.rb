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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "ref", null: false
    t.integer "user_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name"
    t.string "description"
    t.string "localization", limit: 2
    t.integer "distance"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "bits", limit: 2, default: "32", null: false
    t.string "endianness", limit: 6, default: "little", null: false
    t.integer "max_mem", default: 2097152, null: false
    t.integer "disk_max_size", default: 67108864, null: false
    t.integer "disk_max_files", default: 512, null: false
    t.integer "disk_max_file_descriptors", default: 32, null: false
    t.bigint "network_max_send", default: 134217728, null: false
    t.bigint "network_max_receive", default: 134217728, null: false
    t.integer "network_max_sockets", default: 32, null: false
    t.integer "network_nb_ports", default: 1, null: false
    t.integer "network_send_speed", default: 51200, null: false
    t.integer "network_receive_speed", default: 51200, null: false
    t.decimal "udp_drop_ratio", precision: 3, scale: 2, default: "0.0", null: false
    t.text "code", null: false
    t.text "script", null: false
    t.integer "nb_splayds", default: 1, null: false
    t.decimal "factor", precision: 3, scale: 2, default: "1.25", null: false
    t.string "splayd_version"
    t.decimal "max_load", precision: 5, scale: 2, default: "999.99", null: false
    t.integer "min_uptime", default: 0, null: false
    t.string "hostmasks"
    t.integer "max_time", default: 10000
    t.string "die_free", limit: 5, default: "TRUE"
    t.string "keep_files", limit: 5, default: "FALSE"
    t.string "scheduler", limit: 8, default: "standard"
    t.text "scheduler_description"
    t.string "list_type", limit: 6, default: "HEAD"
    t.integer "list_size", default: 0, null: false
    t.string "command"
    t.text "command_msg"
    t.string "status", limit: 16, default: "LOCAL"
    t.integer "status_time", null: false
    t.text "status_msg"
    t.index ["ref"], name: "ref"
  end

  create_table "splayd_availabilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "splayd_id", null: false
    t.string "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", limit: 11, default: "AVAILABLE"
    t.integer "time", null: false
  end

  create_table "splayds", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "key", null: false
    t.string "ip"
    t.string "hostname"
    t.string "session"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "country", limit: 2
    t.string "city"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "version"
    t.string "lua_version"
    t.string "bits", limit: 2, default: "32"
    t.string "endianness", limit: 6, default: "little"
    t.string "os"
    t.string "full_os"
    t.integer "start_time"
    t.decimal "load_1", precision: 5, scale: 2, default: "999.99"
    t.decimal "load_5", precision: 5, scale: 2, default: "999.99"
    t.decimal "load_15", precision: 5, scale: 2, default: "999.99"
    t.integer "max_number"
    t.integer "max_mem"
    t.integer "disk_max_size"
    t.integer "disk_max_files"
    t.integer "disk_max_file_descriptors"
    t.bigint "network_max_send"
    t.bigint "network_max_receive"
    t.integer "network_max_sockets"
    t.integer "network_max_ports"
    t.integer "network_send_speed"
    t.integer "network_receive_speed"
    t.string "command", limit: 6
    t.string "status", limit: 12, default: "REGISTERED"
    t.integer "last_contact_time"
    t.index ["ip"], name: "ip"
    t.index ["key"], name: "key"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer "admin", default: 0
    t.integer "demo", default: 1
  end

end