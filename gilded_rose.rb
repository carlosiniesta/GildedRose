class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      klass = UpdaterSelector.run(item)
      klass.run(item)
    end
  end
end

class UpdaterSelector
  KNOW_LEGENDARY_ITEMS = ["sulfuras"].freeze

  def self.run(item)
    new(item).run
  end

  attr_reader :item
  def initialize(item)
    @item = item
  end

  def run
    if is_brie?
      BrieUpdater
    elsif is_legendary?
      LegendaryUpdater
    elsif is_backstage_pass?
      BackStagePassUpdater
    elsif is_conjured?
      ConjuredUpdater
    else
      ItemUpdater
    end
  end

  def is_brie?
    item.name.downcase.match(/brie/)
  end

  def is_legendary?
    KNOW_LEGENDARY_ITEMS.select {|name| item.name.downcase.match(name)}.any?
  end

  def is_backstage_pass?
    item.name.downcase.match(/backstage passes/)
  end

  def is_conjured?
    item.name.downcase.match(/conjured/)
  end
end

class ItemUpdater
  def self.run(item)
    new(item).run
  end

  attr_accessor :item
  def initialize(item)
    @item = item
  end

  def run
    update_quality
    update_sell_in
  end

  def update_quality
    item.quality -= fluctuaction_factor
    item.quality = 0 if item.quality.negative?
    item.quality = 50 if item.quality > 50
  end

  def update_sell_in
    item.sell_in -= 1
  end

  def fluctuaction_factor
    item.sell_in.zero? ? 2 : 1
  end
end

class BrieUpdater < ItemUpdater
  def fluctuaction_factor
    -1
  end
end

class LegendaryUpdater < ItemUpdater
  def self.run(item)
  end
end

class BackStagePassUpdater < ItemUpdater
  def fluctuaction_factor
    if item.sell_in > 10
      -1
    elsif item.sell_in < 0
      item.quality
    elsif item.sell_in < 5
      -2
    else #item.sell_in.between?(5,10)
      -3
    end
  end
end

class ConjuredUpdater < ItemUpdater
  def fluctuaction_factor
    super * 2
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
