class KFSopranosQuotes extends Mutator
    config(KFSopranosQuotes);


var private config array<string> Messages;

struct sColorTag {
    var string Tag;
    var Color C;
};
var private array<sColorTag> Colors;

var private transient array<PlayerController> GreetedPCs;

struct sPendingGreeting {
    var PlayerController pc;
    var string msg;
    var int repeatsLeft;
};
var private transient array<sPendingGreeting> PendingGreetings;

function ModifyPlayer(Pawn Other) {
    local PlayerController pc;
    local int i;

    super.ModifyPlayer(Other);

    if (Other == none)
        return;

    pc = PlayerController(Other.Controller);
    if (pc == none)
        return;

    for (i = 0; i < GreetedPCs.length; i++) {
        if (GreetedPCs[i] == pc)
            return;
    }

    SendGreeting(pc);
    GreetedPCs[GreetedPCs.length] = pc;
}

private final function SendGreeting(PlayerController pc) {
    local int count, idx;
    local sPendingGreeting entry;

    count = Messages.length;
    if (count == 0)
        return;

    idx = Rand(count);
    entry.msg = Messages[idx];
    entry.pc = pc;
    entry.repeatsLeft = 2;

    entry.msg = ParseTags(entry.msg);
    pc.teamMessage(none, entry.msg, 'KFSopranosQuotes');
    PendingGreetings[PendingGreetings.length] = entry;
    SetTimer(3.0, true);
}

function Timer() {
    local int i;

    for (i = PendingGreetings.length - 1; i >= 0; i--) {
        if (PendingGreetings[i].pc == none) {
            PendingGreetings.Remove(i, 1);
            continue;
        }
        PendingGreetings[i].pc.teamMessage(none, PendingGreetings[i].msg, 'KFSopranosQuotes');
        PendingGreetings[i].repeatsLeft--;
        if (PendingGreetings[i].repeatsLeft <= 0)
            PendingGreetings.Remove(i, 1);
    }

    if (PendingGreetings.length == 0)
        SetTimer(0, false);
}

function NotifyLogout(Controller Exiting) {
    local int i;

    for (i = GreetedPCs.length - 1; i >= 0; i--) {
        if (GreetedPCs[i] == none || GreetedPCs[i] == Exiting)
            GreetedPCs.Remove(i, 1);
    }

    for (i = PendingGreetings.length - 1; i >= 0; i--) {
        if (PendingGreetings[i].pc == none || PendingGreetings[i].pc == Exiting)
            PendingGreetings.Remove(i, 1);
    }

    super.NotifyLogout(Exiting);
}

private final function string ParseTags(string input) {
    local int i;

    for (i = 0; i < Colors.length; i++) {
        ReplaceText(input, Colors[i].Tag, class'GameInfo'.static.MakeColorCode(Colors[i].C));
    }
    return input;
}

defaultproperties {
    Colors(0)=(Tag="^r",C=(R=255,G=0,B=0,A=0))
    Colors(1)=(Tag="^g",C=(R=0,G=255,B=0,A=0))
    Colors(2)=(Tag="^b",C=(R=0,G=100,B=200,A=0))
    Colors(3)=(Tag="^y",C=(R=255,G=255,B=0,A=0))
    Colors(4)=(Tag="^w",C=(R=255,G=255,B=255,A=0))
    Colors(5)=(Tag="^o",C=(R=200,G=77,B=0,A=0))
    GroupName="KF-SopranosQuotes"
    FriendlyName="Sopranos Quotes"
    Description="Random Sopranos quotes on spawn."
}
