"""SRT — word-coverage gate + never-drop-words cue construction (§5/§6)."""
import json

import validate_srt_coverage as vc


SCENES = [
    {"id": "S001", "type": "TITLE",
     "narration": "Welcome to the Terraform Azure labs. Today we deploy a storage account."},
    {"id": "S002", "type": "CODE",
     "narration": "The resource block defines an azurerm storage account.",
     "steps": [
         {"narration": "The resource block defines an azurerm storage account."},
         {"narration": "Account tier is standard and replication is LRS."},
     ]},
]

SRT_FULL = """1
00:00:00,000 --> 00:00:05,000
Welcome to the Terraform Azure labs. Today we deploy a storage account.

2
00:00:05,000 --> 00:00:09,000
The resource block defines an azurerm storage account.

3
00:00:09,000 --> 00:00:12,000
Account tier is standard and replication is LRS.
"""

SRT_DROPPED = """1
00:00:00,000 --> 00:00:05,000
Welcome to the Terraform Azure labs. Today we deploy a storage account.
"""


def make_ep(tmp_path, srt_text):
    ep = tmp_path / "ep"
    (ep / "writing").mkdir(parents=True)
    (ep / "final").mkdir(parents=True)
    (ep / "writing" / "scenes.json").write_text(
        json.dumps({"scenes": SCENES}), encoding="utf-8")
    (ep / "final" / "episode.srt").write_text(srt_text, encoding="utf-8")
    return ep


def test_steps_are_the_spoken_text():
    txt = vc.spoken_text(SCENES)
    assert "Welcome to the Terraform" in txt
    # step narration only once — the top-level CODE narration is not spoken twice
    assert txt.count("defines an azurerm storage account") == 1


def test_coverage_full_is_100():
    words = vc.normalize("the cat sat on the mat")
    assert vc.coverage(words, vc.normalize("the cat sat on the mat")) == 100.0


def test_coverage_multiset_not_set():
    # one "cat" in narration, two "cats"... multiset: partial counts once only
    assert vc.coverage(["cat", "cat"], ["cat"]) == 50.0


def test_validate_passes_when_everything_is_carried(tmp_path):
    report, fails = vc.validate(make_ep(tmp_path, SRT_FULL), scenes=SCENES)
    assert fails == []
    assert report["status"] == "pass"


def test_validate_fails_when_words_dropped(tmp_path):
    report, fails = vc.validate(make_ep(tmp_path, SRT_DROPPED), scenes=SCENES)
    assert fails and any("coverage" in f for f in fails)


def test_tag_never_leaks_into_srt(tmp_path):
    leak = SRT_FULL.replace("Welcome to", "<#1.5#>Welcome to")
    ep = make_ep(tmp_path, leak)
    report, fails = vc.validate(ep, scenes=SCENES)
    assert any("leak" in f for f in fails)


def test_overlapping_cues_fail(tmp_path):
    bad = """1
00:00:00,000 --> 00:00:05,000
Welcome to the Terraform Azure labs.

2
00:00:04,000 --> 00:00:09,000
The resource block defines an azurerm storage account.

3
00:00:09,000 --> 00:00:12,000
Account tier is standard and replication is LRS.
"""
    ep = make_ep(tmp_path, bad)
    report, fails = vc.validate(ep, scenes=SCENES)
    assert any("overlap" in f for f in fails)