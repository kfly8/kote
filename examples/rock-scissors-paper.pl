use v5.40;

use Types::Common -types;
use Devel::StrictMode;
use List::Util qw(sample);

use constant {
    ROCK     => 1,
    SCISSORS => 2,
    PAPER    => 3,
};
use constant HANDS => [ROCK, SCISSORS, PAPER];

use kote Hand => Enum HANDS;
use kote Player => StrLength[1, 10];

use kote PlayerHand => Dict[
    player => Player,
    hand   => Hand,
];

use kote Draw => Undef;

use kote GameWinner => Dict[
    winner => Player,
    round_count => Int,
];
use constant GAME_ERROR_NO_WINER => 'No winner';
use kote GameErrorNoWinner => Enum[GAME_ERROR_NO_WINER];

# pick a random hand
sub pick_hand() { sample 1, HANDS->@*; }

# play a game between two players
#
# returns
#     GameWinner
#   | GameErrorNoWinner
sub play_game($player1, $player2) {
    STRICT && Player->assert_valid($player1);
    STRICT && Player->assert_valid($player2);

    my $round_count = 0;
    my $winner;

    while (true) {
        $round_count++;

        my $player_hand1 = { player => $player1, hand => pick_hand() };
        my $player_hand2 = { player => $player2, hand => pick_hand() };

        my $result = round($player_hand1, $player_hand2);

        if (Draw->check($result)) {
            next if $round_count < 5;
            last;
        }
        else {
            $winner = $result;
            last;
        }
    }

    if (!$winner) {
        return (undef, GAME_ERROR_NO_WINER);
    }

    GameWinner->create({ winner => $winner, round_count => $round_count });
}

# returns Player | Draw
#   Player if there is a winner
#   Draw if there is a draw
sub round($player_hand1, $player_hand2) {
    STRICT && PlayerHand->assert_valid($player_hand1);
    STRICT && PlayerHand->assert_valid($player_hand2);

    my $hand1 = $player_hand1->{hand};
    my $hand2 = $player_hand2->{hand};

    if ($hand1 == $hand2) {
        return undef;
    }
    elsif (
        $hand1 == ROCK     && $hand2 == SCISSORS ||
        $hand1 == SCISSORS && $hand2 == PAPER ||
        $hand1 == PAPER    && $hand2 == ROCK
    ) {
        return $player_hand1->{player};
    }
    else {
        return $player_hand2->{player};
    }
}

sub show_result($game_result) {
    if (GameWinner->check($game_result)) {
        say "Winner: " . $game_result->{winner} . " in " . $game_result->{round_count} . " rounds";
    }
    elsif (GameErrorNoWinner->check($game_result)) {
        say "No winner";
        return;
    }
    else {
        die "Unknown game result";
    }
}

sub main() {
    my $err;

    (my $player1, $err) = Player->create('Foo');
    die $err if $err;

    (my $player2, $err) = Player->create('Bar');
    die $err if $err;

    (my $game_result, $err) = play_game($player1, $player2);
    die $err if $err;

    show_result($game_result);
}

main();
