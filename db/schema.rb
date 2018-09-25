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

ActiveRecord::Schema.define(version: 20180126063743) do

  create_table "coin_feeds", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "feed_type", limit: 55
    t.integer "star"
    t.text "content"
    t.integer "up_point"
    t.integer "down_point"
    t.datetime "publish_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "source_url"
    t.string "link_name"
    t.string "link"
    t.integer "source_id"
    t.string "website", limit: 55
    t.text "tag_str"
  end

  create_table "coin_markets", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "symbol", limit: 55
    t.string "market_code"
    t.string "exchange_way", comment: "交易对"
  end

  create_table "coin_stats", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "symbol", comment: "币简称"
    t.string "fxh_symbol"
    t.string "symbol_zh", comment: "币中文"
    t.string "symbol_type", comment: "币类型"
    t.string "country"
    t.string "currency"
    t.decimal "curr_market_value", precision: 20, scale: 3, comment: "当前总市值"
    t.decimal "pub_price", precision: 20, scale: 7, comment: "发行价"
    t.datetime "pub_at", comment: "发行时间"
    t.decimal "max_up_per", precision: 15, scale: 2, comment: "发行价最高涨幅度"
    t.decimal "curr_up_per", precision: 15, scale: 2, comment: "发行价当前涨幅度"
    t.datetime "high_at", comment: "最高价时间"
    t.decimal "high_price", precision: 20, scale: 7
    t.decimal "low_price", precision: 20, scale: 7
    t.decimal "curr_price", precision: 20, scale: 7, comment: "现价"
    t.datetime "low_at"
    t.integer "curr_max_value", comment: "最高总市值"
    t.decimal "curr_hour24_up", precision: 11, scale: 1, comment: "上线总时间"
    t.decimal "curr_trade_count", precision: 20, scale: 7, comment: "流通数量"
    t.decimal "curr_trade_volume", precision: 20, scale: 7, comment: "成交额"
    t.datetime "curr_latest_at", comment: "最新统计时间"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["curr_market_value"], name: "index_market_value"
    t.index ["symbol"], name: "symbol", unique: true
  end

  create_table "coin_stats2", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "symbol", comment: "币简称"
    t.string "symbol_zh", comment: "币中文"
    t.string "symbol_type", comment: "币类型"
    t.string "currency"
    t.datetime "pub_at", comment: "发行时间"
    t.decimal "pub_price", precision: 20, scale: 7, comment: "发行价"
    t.datetime "high_at", comment: "最高价时间"
    t.decimal "high_price", precision: 20, scale: 7
    t.decimal "low_price", precision: 20, scale: 7
    t.decimal "low_at", precision: 20, scale: 7
    t.integer "curr_max_value", comment: "最高总市值"
    t.decimal "curr_price", precision: 20, scale: 7, comment: "现价"
    t.integer "curr_market_value", comment: "当前总市值"
    t.integer "uptime", comment: "上线总时间"
    t.datetime "curr_latest_at", comment: "最新统计时间"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coin_totals", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
  end

  create_table "coin_wikis", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "symbol", limit: 55
    t.string "name_zh"
    t.string "name_en"
    t.datetime "pub_at"
    t.text "desc"
    t.string "white_paper"
    t.string "website"
    t.string "website2"
    t.integer "on_market_count", default: 1
    t.string "country_name"
    t.string "explorer_site"
    t.string "proxy_symbol"
    t.integer "is_proxy", limit: 1
    t.decimal "ico_price_cny", precision: 20, scale: 7
  end

  create_table "coins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "concepts", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "symbol"
  end

  create_table "countries", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code", limit: 55
    t.string "name"
    t.integer "market_count", comment: "交易市场数据"
    t.integer "coin_count", comment: "货币数量"
  end

  create_table "markets", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code", limit: 55
    t.string "name"
    t.datetime "found_time"
    t.string "country_name"
  end

  create_table "taggings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "ticker_days", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "symbol"
    t.string "currency"
    t.datetime "time"
    t.integer "timestamp"
    t.decimal "price", precision: 20, scale: 7
    t.decimal "avg_price", precision: 20, scale: 7
    t.datetime "start_time", comment: "开始时间"
    t.datetime "end_time", comment: "结束时间"
    t.decimal "open_price", precision: 20, scale: 7, comment: "开盘价"
    t.decimal "high_price", precision: 20, scale: 7, comment: "一周最高价"
    t.decimal "low_price", precision: 20, scale: 7, comment: "一周最低价"
    t.decimal "close_price", precision: 20, scale: 7, comment: "收盘价"
    t.integer "trade_count", comment: "交易数量"
    t.datetime "close_time"
    t.decimal "volume", precision: 30, scale: 5, comment: "成交量"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol", "price"], name: "index_symbol_price"
    t.index ["symbol", "time"], name: "index_symbol_time"
    t.index ["symbol"], name: "index_symbol"
    t.index ["time"], name: "index_time"
  end

  create_table "ticker_times", id: :integer, unsigned: true, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
  end

  create_table "ticker_weeks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "symbol"
    t.datetime "start_time", comment: "开始时间"
    t.datetime "end_time", comment: "结束时间"
    t.decimal "open_price", precision: 20, scale: 7, comment: "开盘价"
    t.decimal "high_price", precision: 20, scale: 7, comment: "一周最高价"
    t.decimal "low_price", precision: 20, scale: 7, comment: "一周最低价"
    t.decimal "close_price", precision: 20, scale: 7, comment: "收盘价"
    t.integer "trade_count", comment: "交易数量"
    t.datetime "close_time"
    t.decimal "volume", precision: 30, scale: 5, comment: "成交量"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
