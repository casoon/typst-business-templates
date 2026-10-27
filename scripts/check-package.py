#!/usr/bin/env python3
"""Package contracts: locale merging, identity, masking and tagged publications.

Uses the same typstgen binary as check.sh; pypdf inspects the generated PDFs.
Only synthetic values are generated here. Artifacts live in a temporary directory.
"""
import argparse
import json
import shutil
from pathlib import Path
import subprocess
import tempfile

from pypdf import PdfReader

REPO = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--artifacts-dir", type=Path)
artifacts_dir = parser.parse_args().artifacts_dir
if artifacts_dir:
    artifacts_dir.mkdir(parents=True, exist_ok=True)


def check(condition, message):
    if not condition:
        raise AssertionError(message)


with tempfile.TemporaryDirectory(prefix="business-templates-check-") as directory:
    root = Path(directory)
    config = root / "typstgen.toml"
    config.write_text(
        f'template_paths = ["."]\npackage_path = {json.dumps(str(REPO / "packages"))}\n'
        f'font_paths = [{json.dumps(str(REPO / "fonts"))}]\n'
    )

    def compile_source(name, source, error=None, standard=None):
        path = root / f"{name}.typ"
        path.write_text(source)
        output = path.with_suffix(".pdf")
        args = ["typstgen", "compile", str(path), "-c", str(config), "-o", str(output),
                "--creation-timestamp", "1792972800"]
        if standard:
            args += ["--pdf-standard", standard]
        result = subprocess.run(args, cwd=root, capture_output=True, text=True)
        if error:
            check(result.returncode != 0 and error in result.stderr,
                  f"{name}: expected {error!r}, got {result.stderr}")
            return
        check(result.returncode == 0, f"{name}: {result.stderr}")
        if artifacts_dir:
            shutil.copyfile(output, artifacts_dir / output.name)
        return PdfReader(output)

    def text(reader):
        return "\n".join(page.extract_text() for page in reader.pages)

    locale_import = '#import "@local/business-templates:0.2.0" as pkg\n'
    prefix = locale_import + "#let load-locale = pkg.load-locale\n"
    compile_source("locale-contract", prefix + '''
#let base = load-locale(none, (language: "en"))
#let merged = load-locale((common: (page: "Sheet", date: none), custom: (project: "Private label")), (language: "en"))
#assert(merged.common.page == "Sheet")
#assert(merged.common.date == base.common.date)
#assert(merged.invoice == base.invoice)
#assert(merged.custom.project == "Private label")
#assert(load-locale((common: (page: "",)), (:)).common.page == "")
#assert(load-locale(base, (language: "en")) == base)
#assert(load-locale((:), (language: "de"), language: "en") == base)
Locale contract
''')
    for name, override, message in [
        ("branch", '(common: "wrong")', "locale.common: expected dictionary"),
        ("leaf", '(common: (page: 1))', "locale.common.page: expected string"),
        ("root", '"wrong"', "locale: expected dictionary"),
    ]:
        compile_source("locale-" + name, prefix + f'#load-locale({override}, (:))', error=message)
    compile_source("locale-language", prefix + '#load-locale(none, (language: "xx"))',
                   error="locale: unsupported language")

    for template in ["concept", "documentation", "contract", "proposal", "protocol", "sla", "specification"]:
        author = ', authors: ("Synthetic Author",)' if template in ["concept", "documentation", "proposal", "specification"] else ""
        reader = compile_source("identity-" + template, locale_import + f'''
#show: pkg.{template}.with(title: "Synthetic title", document_number: "DOC-2026-001", created_at: "2026-10-26", company: (name: "Example Studio",), show_toc: false{author})
= Body
Synthetic document content.
''')
        check(reader.metadata.title == "Synthetic title", template + ": title lost")
        check("DOC-2026-001" in reader.metadata.get("/Keywords", ""), template + ": identifier lost")
        check(reader.metadata.creation_date.year == 2026, template + ": wrong date")
        check(reader.metadata.author == ("Synthetic Author" if author else "Example Studio"), template + ": author lost")
        check("DOC-2026-001" in text(reader), template + ": visible identity lost")
    reader = compile_source("no-date", locale_import + '#show: pkg.concept.with(title: "Undated", show_toc: false)\nBody')
    check(reader.metadata.creation_date is None, "Missing document date must stay absent")
    reader = compile_source("year-only", locale_import + '#show: pkg.concept.with(title: "Year only", created_at: "2025", show_toc: false)\nBody')
    check(reader.metadata.creation_date is None, "Year-only label must not invent a PDF date")
    check("2025" in text(reader), "Year-only label must remain visible")

    sentinel = "SYNTHETIC-PASSWORD-ONLY-12345"
    data = {
        "metadata": {"title": "Synthetic credentials", "document_number": "CRED-2026-001",
                     "client_name": "Example Client", "project_name": "Test", "created_at": {"date": "2026-10-26"}},
        "services": [{"name": f"Example service {i}", "url": "https://example.invalid",
                      "credentials": [{"username": "example", "password": sentinel},
                                      {"username": "empty", "password": ""},
                                      {"username": "null", "password": None}, {"username": "missing"}],
                      "notes": "Synthetic note remains visible."} for i in range(18)],
    }
    (root / "credentials.json").write_text(json.dumps(data))
    for masked in [False, True]:
        reader = compile_source("masked" if masked else "plain", locale_import + f'''
#pkg.credentials(data: json("credentials.json"), company: (name: "Example Studio", language: "en"), mask: {str(masked).lower()})
''')
        output = text(reader)
        check((sentinel not in output) if masked else (sentinel in output), "Credential masking failed")
        check("Synthetic note remains visible." in output, "Masking removed unrelated notes")
        check(len(reader.pages) > 2, "Credentials did not exercise continuation pages")
        check(not reader.attachments, "Credentials unexpectedly contain attachments")
        check(sentinel not in str(reader.metadata), "Password leaked into metadata")
        if masked:
            check("********" in output, "Mask is missing")

    for source in sorted((REPO / "examples/publication").glob("*.typ")):
        result = subprocess.run(["typstgen", "compile", source.name, "-o", str(root / source.with_suffix('.pdf').name),
                                 "--pdf-standard", "ua-1"], cwd=source.parent, capture_output=True, text=True)
        check(result.returncode == 0, source.name + ": " + result.stderr)
        if artifacts_dir:
            shutil.copyfile(root / source.with_suffix('.pdf').name, artifacts_dir / source.with_suffix('.pdf').name)
        reader = PdfReader(root / source.with_suffix('.pdf').name)
        check(len(reader.pages) >= 2, source.name + ": expected continuation pages")
        check("/StructTreeRoot" in reader.trailer["/Root"], source.name + ": missing PDF tags")
        if source.stem == "guide":
            def roles(node):
                if isinstance(node, list):
                    return [role for child in node for role in roles(child)]
                node = node.get_object() if hasattr(node, "get_object") else node
                if isinstance(node, dict):
                    return [node.get("/S")] + roles(node.get("/K", []))
                return []
            check("/TH" in roles(reader.trailer["/Root"]["/StructTreeRoot"]), "Table header semantics missing")
            content = text(reader)
            check(content.index("Preparation") < content.index("Discovery") < content.index("Review gate"), "Publication reading order changed")
        if source.stem == "brochure":
            check(reader.pages[0].mediabox.width > reader.pages[0].mediabox.height, "Brochure is not landscape")

    reader = compile_source("empty-task-options", locale_import + '#pkg.task-list(title: "Minimal", company: (language: "en"), created: none, show-title-page: false, tasks: ((title: "One task", phase: "", assignee: none),))[]')
    check("Responsible:" not in text(reader) and "Phase:" not in text(reader), "Empty task metadata produced labels")

    compile_source("minimal-publication", locale_import + '#show: pkg.publication.with(title: "A long title " * 15)\nBody', standard="ua-1")
    compile_source("custom-brochure", locale_import + '#show: pkg.brochure.with(title: "Custom", width: 240mm, height: 180mm)\nBody', standard="ua-1")
    logo = '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="30"><rect width="120" height="30" fill="#244B62"/></svg>'
    (root / "logo.svg").write_text(logo)
    compile_source("publication-logo", locale_import + '#show: pkg.publication.with(title: "With logo", logo: image("logo.svg", height: 9mm, alt: "Example Studio"))\nBody', standard="ua-1")
    compile_source("dark-brochure", locale_import + '#show: pkg.brochure.with(title: "Dark page", foreground: white, background: rgb("#182C39"), accent: rgb("#C4E6FC"))\nBody', standard="ua-1")

print("ok   package contracts (locales, masking, metadata, publications, PDF structure)")
