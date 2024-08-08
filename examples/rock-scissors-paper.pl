# Simple rock-scissors-paper game
#
# Usage:
#   perl rock-scissors-paper.pl name1 name2 name3 ...
#   # => Winner: {name}
#
# Spec:
#   - The number of players ranges from 2 to 10.
#   - The game continues until a winner is determined.
#   - The player name is a string of 1 to 10 characters.
#   - Each player randomly selects one of Rock, Paper, or Scissors.
#   - If there is a draw for 100 consecutive rounds, the game ends in a error.

use v5.40;

use Types::Common -types;
use Devel::StrictMode;
use List::Util qw(sample);

use constant {
    ROCK     => 1,
    SCISSORS => 2,
    PAPER    => 3,
};

use kote Hand => Enum[ROCK, SCISSORS, PAPER];
use kote Player => StrLength[1, 10];

use kote PlayerHand => Dict[
    player => Player,
    hand   => Hand,
];

use kote GameResult => Dict[
    winner => Player,
];

use constant MIN_PLAYERS => 2;
use constant MAX_PLAYERS => 10;
use constant MAX_ROUNDS  => 100;

use constant {
    GAME_ERROR_TOO_FEW_PLAYERS  => 'TooFewPlayers',  # players < MIN_PLAYERS
    GAME_ERROR_TOO_MANY_PLAYERS => 'TooManyPlayers', # players > MAX_PLAYERS
    GAME_ERROR_TOO_MANY_ROUNDS  => 'TooManyRounds',  # round_count > MAX_ROUNDS
};

use kote GameError => Enum[
    GAME_ERROR_TOO_FEW_PLAYERS,
    GAME_ERROR_TOO_MANY_PLAYERS,
    GAME_ERROR_TOO_MANY_ROUNDS,
];

# play a game between multiple players
#
# returns (GameResult, Undef) | (Undef, GameError)
sub play_game($players) {
    STRICT && Player->item_of(ArrayRef)->assert_valid($players);

    if ($players->@* < MIN_PLAYERS) {
        return (undef, GAME_ERROR_TOO_FEW_PLAYERS);
    }

    if ($players->@* > MAX_PLAYERS) {
        return (undef, GAME_ERROR_TOO_MANY_PLAYERS);
    }

    my $round_count = 0;

    while (true) {
        $round_count++;

        if ($round_count > MAX_ROUNDS) {
            return (undef, GAME_ERROR_TOO_MANY_ROUNDS);
        }

        my $player_hands = [ map { { player => $_, hand => pick_hand() } } $players->@* ];
        my $winners = round($player_hands);

        if ($winners->@* == 0) {
            next;
        }
        elsif ($winners->@* == 1) {
            return GameResult->create({ winner => $winners->[0] });
        }
        else {
            return play_game($winners->@*);
        }
    }
}

# returns ArrayRef[Player]
#   - empty array if draw
sub round($player_hands) {
    STRICT && do { PlayerHand->assert_valid($_) for @$player_hands };

    my %hands;
    push $hands{$_->{hand}}->@* => $_->{player} for @$player_hands;

    my $count = keys %hands;

    if ($count == 1 || $count == 3) { # Draw
        return [];
    }
    else {
        my ($hand1, $hand2) = keys %hands;
        if ($hand1 == ROCK     && $hand2 == SCISSORS ||
            $hand1 == SCISSORS && $hand2 == PAPER ||
            $hand1 == PAPER    && $hand2 == ROCK) {
            return $hands{$hand1};
        }
        else {
            return $hands{$hand2};
        }
    }
}

sub show_result($game_result) {
    STRICT && GameResult->assert_valid($game_result);

    my $winner = $game_result->{winner};
    say "Winner: $winner";
}

sub show_error_result($err) {
    STRICT && GameError->assert_valid($err);

    say "Error: $err";
}

# Select one of hands randomly
sub pick_hand() { sample 1, (ROCK, SCISSORS, PAPER); }

sub main() {
    my @player_names = @ARGV;

    my $err;

    (my $players, $err) = Player->item_of(ArrayRef)->create(\@player_names);
    die $err if $err;

    (my $game_result, $err) = play_game($players);
    if ($err) {
        show_error_result($err);
    }
    else {
        show_result($game_result);
    }
}

main();
