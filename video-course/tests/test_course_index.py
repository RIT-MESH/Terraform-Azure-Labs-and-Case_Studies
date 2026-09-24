"""Lab resolution — course_index.resolve_lab (short-command contract §2)."""
import course_index


LABS = [
    {"section": "section-01-foundations", "lab": "01-authentication-app-object",
     "path": "section-01-foundations/01-authentication-app-object", "number": 1},
    {"section": "section-01-foundations", "lab": "02-storage-account",
     "path": "section-01-foundations/02-storage-account", "number": 2},
    {"section": "section-01-foundations", "lab": "12-subnet-resource",
     "path": "section-01-foundations/12-subnet-resource", "number": 12},
]


def test_prefix_resolves():
    assert course_index.resolve_lab("01", LABS)[0]["lab"] == "01-authentication-app-object"


def test_bare_number_resolves():
    assert course_index.resolve_lab("2", LABS)[0]["lab"] == "02-storage-account"


def test_exact_name_resolves():
    hits = course_index.resolve_lab("12-subnet-resource", LABS)
    assert hits[0]["lab"] == "12-subnet-resource"


def test_all_returns_every_lab():
    assert course_index.resolve_lab("all", LABS) == LABS


def test_ambiguous_raises():
    # "0" matches every lab number/name and is not a unique prefix
    try:
        course_index.resolve_lab("0", LABS)
        assert False, "expected SystemExit"
    except SystemExit:
        pass


def test_unknown_raises():
    try:
        course_index.resolve_lab("99", LABS)
        assert False, "expected SystemExit"
    except SystemExit:
        pass