use std::fs;
use std::path::PathBuf;
use std::process::Command;
use tempfile::TempDir;

fn docgen_binary() -> PathBuf {
    PathBuf::from(env!("CARGO_BIN_EXE_docgen"))
}

fn setup_test_project() -> TempDir {
    let tmp = TempDir::new().unwrap();
    let data_dir = tmp.path().join("data");
    fs::create_dir_all(&data_dir).unwrap();

    fs::write(data_dir.join("clients.json"), "[]").unwrap();
    fs::write(data_dir.join("projects.json"), "[]").unwrap();
    fs::write(
        data_dir.join("counters.json"),
        r#"{"client":0,"invoice":0,"offer":0,"credentials":0,"concept":0,"documentation":0}"#,
    )
    .unwrap();

    tmp
}

fn add_test_client(tmp: &TempDir, name: &str) -> String {
    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg(name)
        .current_dir(tmp.path())
        .output()
        .expect("Failed to add client");

    let stdout = String::from_utf8_lossy(&output.stdout);
    // Extract client number (K-001)
    stdout
        .lines()
        .find(|line| line.contains("K-"))
        .and_then(|line| {
            line.split_whitespace()
                .find(|word| word.starts_with("K-"))
                .map(|s| s.to_string())
        })
        .unwrap_or_else(|| "K-001".to_string())
}

#[test]
fn test_project_list_empty() {
    let tmp = setup_test_project();
    let client_id = add_test_client(&tmp, "Test Client");

    let output = Command::new(docgen_binary())
        .arg("project")
        .arg("list")
        .arg(&client_id)
        .current_dir(tmp.path())
        .output()
        .expect("Failed to list projects");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Test Client"));
}

#[test]
fn test_project_add() {
    let tmp = setup_test_project();
    let client_id = add_test_client(&tmp, "Project Test Client");

    let output = Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg(&client_id)
        .arg("Test Project")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to add project");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("P-001-01")); // First project for first client

    // Verify JSON file
    let projects_json = fs::read_to_string(tmp.path().join("data/projects.json")).unwrap();
    assert!(projects_json.contains("Test Project"));
}

#[test]
fn test_project_per_client_numbering() {
    let tmp = setup_test_project();

    // Add two clients
    let client1 = add_test_client(&tmp, "Client One");
    let client2 = add_test_client(&tmp, "Client Two");

    // Add projects for client 1
    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg(&client1)
        .arg("Project 1A")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg(&client1)
        .arg("Project 1B")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Add project for client 2
    let output = Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg(&client2)
        .arg("Project 2A")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("P-002-01")); // First project for second client

    // Verify projects.json structure
    let projects_json = fs::read_to_string(tmp.path().join("data/projects.json")).unwrap();
    let parsed: serde_json::Value = serde_json::from_str(&projects_json).unwrap();
    let projects = parsed.as_array().unwrap();

    assert_eq!(projects.len(), 3);

    // Check client 1 projects
    let client1_projects: Vec<_> = projects.iter().filter(|p| p["client_id"] == 1).collect();
    assert_eq!(client1_projects.len(), 2);

    // Check client 2 projects
    let client2_projects: Vec<_> = projects.iter().filter(|p| p["client_id"] == 2).collect();
    assert_eq!(client2_projects.len(), 1);
    assert_eq!(client2_projects[0]["number"], 1); // Numbering resets per client
}

#[test]
fn test_project_delete() {
    let tmp = setup_test_project();

    // Add client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Test Client")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Add two projects
    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg("K-001")
        .arg("Project A")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg("K-001")
        .arg("Project B")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Delete second project
    let output = Command::new(docgen_binary())
        .arg("project")
        .arg("delete")
        .arg("P-001-02")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to delete project");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("deleted successfully"));

    // Verify only one project remains
    let projects_json = fs::read_to_string(tmp.path().join("data/projects.json")).unwrap();
    let projects: Vec<serde_json::Value> = serde_json::from_str(&projects_json).unwrap();
    assert_eq!(projects.len(), 1);
    assert_eq!(projects[0]["name"], "Project A");
}

#[test]
fn test_project_list_with_projects() {
    let tmp = setup_test_project();
    let client_id = add_test_client(&tmp, "List Test Client");

    // Add some projects
    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg(&client_id)
        .arg("Website")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg(&client_id)
        .arg("Mobile App")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // List projects
    let output = Command::new(docgen_binary())
        .arg("project")
        .arg("list")
        .arg(&client_id)
        .current_dir(tmp.path())
        .output()
        .expect("Failed to list projects");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Website"));
    assert!(stdout.contains("Mobile App"));
    assert!(stdout.contains("P-001-01"));
    assert!(stdout.contains("P-001-02"));
}
