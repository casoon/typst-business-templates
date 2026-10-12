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

    // Initialize empty JSON files
    fs::write(data_dir.join("clients.json"), "[]").unwrap();
    fs::write(data_dir.join("projects.json"), "[]").unwrap();
    fs::write(
        data_dir.join("counters.json"),
        r#"{"client":0,"invoice":0,"offer":0,"credentials":0,"concept":0,"documentation":0}"#,
    )
    .unwrap();

    tmp
}

#[test]
fn test_client_list_empty() {
    let tmp = setup_test_project();

    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("list")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to execute docgen");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Keine Kunden") || stdout.contains("No clients"));
}

#[test]
fn test_client_add() {
    let tmp = setup_test_project();

    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Test Client")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to execute docgen");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("K-001"));

    // Verify JSON file was created
    let clients_json = fs::read_to_string(tmp.path().join("data/clients.json")).unwrap();
    assert!(clients_json.contains("Test Client"));

    // Verify counter was incremented
    let counters_json = fs::read_to_string(tmp.path().join("data/counters.json")).unwrap();
    let counters: serde_json::Value = serde_json::from_str(&counters_json).unwrap();
    assert_eq!(counters["client"], 1);
}

#[test]
fn test_client_list_with_clients() {
    let tmp = setup_test_project();

    // Add a client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Test Client")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to add client");

    // List clients
    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("list")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to list clients");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("K-001"));
    assert!(stdout.contains("Test Client"));
}

#[test]
fn test_client_add_multiple() {
    let tmp = setup_test_project();

    // Add first client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Client One")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Add second client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Client Two")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Verify both clients exist
    let clients_json = fs::read_to_string(tmp.path().join("data/clients.json")).unwrap();
    assert!(clients_json.contains("Client One"));
    assert!(clients_json.contains("Client Two"));

    // Verify counter is 2
    let counters_json = fs::read_to_string(tmp.path().join("data/counters.json")).unwrap();
    let counters: serde_json::Value = serde_json::from_str(&counters_json).unwrap();
    assert_eq!(counters["client"], 2);
}

#[test]
fn test_client_add_without_name_fails() {
    let tmp = setup_test_project();

    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to execute docgen");

    assert!(!output.status.success());
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("Name required") || stderr.contains("required arguments"));
}

#[test]
fn test_client_show() {
    let tmp = setup_test_project();

    // Add a client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Show Test Client")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Show client by number
    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("show")
        .arg("K-001")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to show client");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("K-001"));
    assert!(stdout.contains("Show Test Client"));
}

#[test]
fn test_json_file_format() {
    let tmp = setup_test_project();

    // Add a client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("JSON Test")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Verify JSON is valid and pretty-printed
    let clients_json = fs::read_to_string(tmp.path().join("data/clients.json")).unwrap();
    let parsed: serde_json::Value = serde_json::from_str(&clients_json).expect("Invalid JSON");

    assert!(parsed.is_array());
    let clients = parsed.as_array().unwrap();
    assert_eq!(clients.len(), 1);

    let client = &clients[0];
    assert_eq!(client["name"], "JSON Test");
    assert_eq!(client["number"], 1);
    assert!(client["id"].is_number());
    assert!(client["created_at"].is_string());
}

#[test]
fn test_client_delete() {
    let tmp = setup_test_project();

    // Add two clients
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Client One")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Client Two")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Delete the second client
    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("delete")
        .arg("K-002")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to delete client");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("deleted successfully"));

    // Verify only one client remains
    let clients_json = fs::read_to_string(tmp.path().join("data/clients.json")).unwrap();
    let clients: Vec<serde_json::Value> = serde_json::from_str(&clients_json).unwrap();
    assert_eq!(clients.len(), 1);
    assert_eq!(clients[0]["name"], "Client One");
}

#[test]
fn test_client_delete_with_projects_fails() {
    let tmp = setup_test_project();

    // Add a client
    Command::new(docgen_binary())
        .arg("client")
        .arg("add")
        .arg("--name")
        .arg("Client With Project")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Add a project for the client
    Command::new(docgen_binary())
        .arg("project")
        .arg("add")
        .arg("K-001")
        .arg("Test Project")
        .current_dir(tmp.path())
        .output()
        .unwrap();

    // Try to delete the client - should fail
    let output = Command::new(docgen_binary())
        .arg("client")
        .arg("delete")
        .arg("K-001")
        .current_dir(tmp.path())
        .output()
        .expect("Failed to execute delete");

    assert!(!output.status.success());
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("Cannot delete client with existing projects"));

    // Verify client still exists
    let clients_json = fs::read_to_string(tmp.path().join("data/clients.json")).unwrap();
    let clients: Vec<serde_json::Value> = serde_json::from_str(&clients_json).unwrap();
    assert_eq!(clients.len(), 1);
}
