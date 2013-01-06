#!/usr/bin/env ruby

class Game
  @@players = []
  @@deck = ((2..10).to_a << %w(A K Q J)).flatten * 4

  def self.players
    @@players
  end

  def initialize
    puts "Welcome to Blackjack!"
    add_dealer
    add_players
    deal
    play
  end

  def play
    display_hidden_hand(dealer)
    @@players.each { |player| display_hand(player) unless player.dealer? }
    print "\n"
    @@players.each { |player| hit_or_stay(player) unless player.dealer? }
    dealer_play
    print "\n"
    winners
  end

  def winners
    winners = []
    @@players.each do |player|
      if player.score > dealer.score && player.score <= 21 && !player.dealer?
        winners << player
      end
    end

    if winners.empty?
      puts "Dealer wins!"
    else
      puts "And the winners are:"
      winners.each do |player|
        display_hand(player)
      end
    end
  end

  def hit_or_stay(player)
    display_hand(player)
    while !done?(player) do
      print "Player #{player.id}: hit or stay (H/S)? " 
      if gets.chomp.downcase == 'h'
        player.hit(self)
      else
        player.stay
        break
      end

      display_hand(player)
    end

    puts "-------------------"
  end

  def done?(player)
    if player.score == 21
      puts "Blackjack!"
      true
    elsif player.score > 21
      puts "Bust!"
      true
    else
      false
    end
  end

  def dealer_play
    display_hand(dealer)
    while dealer.score < 17 do
      puts "Dealer hits!"
      dealer.hit(self)
      display_hand(dealer)
    end

    done?(dealer)
  end

  def display_hidden_hand(player)
    hand = player.hand.dup
    hand[0] = 'X'
    print (player.dealer? ? "Dealer: " : "Player #{player.id}: ")
    puts "#{hand}"
  end

  def display_hand(player) 
    print (player.dealer? ? "Dealer:  " : "Player #{player.id}: ")
    puts "#{player.hand} (#{player.score})"
  end

  def add_players
    print "How many players? "
    gets.chomp.to_i.times { @@players << Player.new }
    print "\n"
  end

  def add_dealer
    @@dealer = Player.new(true)
    @@players << @@dealer
  end

  def dealer
    @@dealer
  end

  def deck
    @@deck
  end

  def deal
    @@players.each do |player|
      2.times { player.hand << deck.delete_at(rand(deck.length)) }
    end
  end
end

class Player
  attr_accessor :hand, :id
  @@next_id = 0

  def initialize(dealer = false)
    @dealer = dealer
    @id = (@@next_id += 1) unless @dealer
    @hand = []
  end

  def hit(game)
    hand << game.deck.delete_at(rand(game.deck.length))
  end

  def stay
    score
  end

  def dealer?
    @dealer
  end

  def score
    score = 0
    hand.each do |card|
      if card.is_a?(String) && card != 'A'
        score += 10
      elsif card != 'A'
        score += card
      end
    end

    if hand.include?('A')
      score += 11 
      score -= 10 if score > 21
    end

    score
  end
end


Game.new


