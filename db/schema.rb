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

ActiveRecord::Schema.define(version: 2018_12_31_133041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", force: :cascade do |t|
    t.bigint "athlete_id"
    t.bigint "workout_type_id"
    t.string "name"
    t.string "description"
    t.float "distance"
    t.integer "moving_time"
    t.integer "elapsed_time"
    t.float "total_elevation_gain"
    t.float "elev_high"
    t.float "elev_low"
    t.datetime "start_date"
    t.datetime "start_date_local"
    t.string "timezone"
    t.integer "athlete_count"
    t.boolean "trainer"
    t.boolean "commute"
    t.boolean "manual"
    t.boolean "private"
    t.string "device_name"
    t.boolean "flagged"
    t.float "average_speed"
    t.float "max_speed"
    t.float "average_cadence"
    t.float "average_temp"
    t.boolean "has_heartrate"
    t.float "average_heartrate"
    t.integer "max_heartrate"
    t.float "calories"
    t.integer "suffer_score"
    t.string "gear_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_activities_on_athlete_id"
    t.index ["gear_id"], name: "index_activities_on_gear_id"
    t.index ["workout_type_id"], name: "index_activities_on_workout_type_id"
  end

  create_table "athlete_infos", primary_key: "athlete_id", force: :cascade do |t|
    t.string "username"
    t.string "firstname"
    t.string "lastname"
    t.string "profile_medium"
    t.string "profile"
    t.bigint "city_id"
    t.bigint "state_id"
    t.bigint "country_id"
    t.string "sex"
    t.integer "follower_count"
    t.integer "friend_count"
    t.integer "athlete_type"
    t.string "date_preference"
    t.string "measurement_preference"
    t.float "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_athlete_infos_on_athlete_id"
    t.index ["city_id"], name: "index_athlete_infos_on_city_id"
    t.index ["country_id"], name: "index_athlete_infos_on_country_id"
    t.index ["state_id"], name: "index_athlete_infos_on_state_id"
    t.index ["username"], name: "index_athlete_infos_on_username"
  end

  create_table "athletes", force: :cascade do |t|
    t.string "access_token"
    t.string "email"
    t.boolean "is_public", default: true
    t.boolean "is_active", default: true
    t.integer "total_run_count", default: 0
    t.integer "last_activity_retrieved"
    t.datetime "last_active_at"
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.boolean "email_confirmed", default: false
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_athletes_on_access_token"
    t.index ["confirmation_token"], name: "index_athletes_on_confirmation_token"
  end

  create_table "best_effort_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_best_effort_types_on_name"
  end

  create_table "best_efforts", force: :cascade do |t|
    t.bigint "activity_id"
    t.bigint "athlete_id"
    t.bigint "best_effort_type_id"
    t.integer "pr_rank"
    t.float "distance"
    t.integer "moving_time"
    t.integer "elapsed_time"
    t.datetime "start_date"
    t.datetime "start_date_local"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_best_efforts_on_activity_id"
    t.index ["athlete_id"], name: "index_best_efforts_on_athlete_id"
    t.index ["best_effort_type_id"], name: "index_best_efforts_on_best_effort_type_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_cities_on_country_id"
    t.index ["name"], name: "index_cities_on_name"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name"
  end

  create_table "faq_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faqs", force: :cascade do |t|
    t.bigint "faq_category_id"
    t.text "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faq_category_id"], name: "index_faqs_on_faq_category_id"
  end

  create_table "gears", primary_key: "gear_id", id: :string, force: :cascade do |t|
    t.bigint "athlete_id"
    t.string "name"
    t.boolean "primary", default: false
    t.float "distance"
    t.string "brand_name"
    t.string "model"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_gears_on_athlete_id"
  end

  create_table "heart_rate_zones", force: :cascade do |t|
    t.bigint "athlete_id"
    t.boolean "custom_zones"
    t.integer "zone_1_min"
    t.integer "zone_1_max"
    t.integer "zone_2_min"
    t.integer "zone_2_max"
    t.integer "zone_3_min"
    t.integer "zone_3_max"
    t.integer "zone_4_min"
    t.integer "zone_4_max"
    t.integer "zone_5_min"
    t.integer "zone_5_max"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_heart_rate_zones_on_athlete_id"
  end

  create_table "race_distances", force: :cascade do |t|
    t.integer "distance"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_race_distances_on_name"
  end

  create_table "races", force: :cascade do |t|
    t.bigint "activity_id"
    t.bigint "athlete_id"
    t.bigint "race_distance_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_races_on_activity_id"
    t.index ["athlete_id"], name: "index_races_on_athlete_id"
    t.index ["race_distance_id"], name: "index_races_on_race_distance_id"
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
    t.index ["name"], name: "index_states_on_name"
  end

  create_table "stripe_customers", id: :string, force: :cascade do |t|
    t.bigint "athlete_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_stripe_customers_on_athlete_id"
  end

  create_table "subscription_plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "duration"
    t.float "amount"
    t.float "amount_per_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "athlete_id"
    t.uuid "subscription_plan_id"
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.boolean "is_active", default: false
    t.boolean "cancel_at_period_end", default: false
    t.boolean "is_deleted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["athlete_id"], name: "index_subscriptions_on_athlete_id"
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
  end

  create_table "workout_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_workout_types_on_name"
  end

  add_foreign_key "activities", "athletes"
  add_foreign_key "activities", "workout_types"
  add_foreign_key "athlete_infos", "athletes"
  add_foreign_key "athlete_infos", "cities"
  add_foreign_key "athlete_infos", "countries"
  add_foreign_key "athlete_infos", "states"
  add_foreign_key "best_efforts", "activities"
  add_foreign_key "best_efforts", "athletes"
  add_foreign_key "best_efforts", "best_effort_types"
  add_foreign_key "cities", "countries"
  add_foreign_key "faqs", "faq_categories"
  add_foreign_key "gears", "athletes"
  add_foreign_key "heart_rate_zones", "athletes"
  add_foreign_key "races", "activities"
  add_foreign_key "races", "athletes"
  add_foreign_key "races", "race_distances"
  add_foreign_key "states", "countries"
  add_foreign_key "stripe_customers", "athletes"
  add_foreign_key "subscriptions", "athletes"
end
