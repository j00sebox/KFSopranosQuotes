class SopranosQuotes extends Mutator
    config(SopranosQuotes);


var private config array<string> Messages;

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

defaultproperties {
    GroupName="KF-SopranosQuotes"
    FriendlyName="Sopranos Quotes"
    Description="Random Sopranos quotes on spawn."
}
