#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! regex = "1"
//! ```

use std::fs;
use std::path::Path;
use std::process::Command;
use regex::Regex;

fn run_terraform(args: &[&str]) -> Result<(), String> {
    let status = Command::new("terraform")
        .args(args)
        .status()
        .map_err(|e| format!("Failed to execute terraform: {}", e))?;
    
    if status.success() {
        Ok(())
    } else {
        Err(format!("terraform exited with status: {}", status))
    }
}

fn delete_all_workspaces() -> Result<(), String> {
    println!("Deleting all existing workspaces...");
    // Get list of workspaces
    let output = Command::new("terraform")
        .args(&["workspace", "list"])
        .output()
        .map_err(|e| format!("Failed to list workspaces: {}", e))?;
    
    if !output.status.success() {
        return Err(format!("Failed to list workspaces, status: {}", output.status));
    }
    
    let workspaces = String::from_utf8_lossy(&output.stdout);
    let active_workspace = workspaces.lines()
        .find(|line| line.starts_with("* "))
        .and_then(|line| line.trim().strip_prefix("* "));
    
    // If there's an active workspace other than default, switch to default
    if let Some(active) = active_workspace {
        if active != "default" {
            println!("Switching from active workspace '{}' to 'default' to allow deletion...", active);
            run_terraform(&["workspace", "select", "default"])
                .map_err(|e| format!("Failed to switch to default workspace: {}", e))?;
        }
    }
    
    // Skip the default workspace and delete others
    workspaces.lines()
        .filter(|line| !line.contains("default"))
        .filter_map(|line| line.trim().strip_prefix("* ").or_else(|| line.trim().strip_prefix("  ")))
        .try_for_each(|ws| {
            println!("Deleting workspace: {}", ws);
            run_terraform(&["workspace", "delete", "-force", ws])
                .map_err(|e| format!("Failed to delete workspace {}: {}", ws, e))
        })
}

fn create_project_workspace() -> Result<(), String> {
    println!("Creating project-wide workspace 'project'...");
    let result = run_terraform(&["workspace", "new", "project"]);
    if result.is_err() {
        println!("Workspace 'project' already exists, attempting to select it...");
        return run_terraform(&["workspace", "select", "project"])
            .map_err(|e| format!("Failed to select 'project' workspace: {}", e));
    }
    result
}

fn create_workspaces_from_directories() -> Result<(), String> {
    let base_dir = Path::new("workspaces");
    if !base_dir.is_dir() {
        return Err(format!("Directory '{}' not found", base_dir.display()));
    }

    let re = Regex::new(r"^(?P<prefix>\d{2})_(?P<name>.+)").unwrap();
    
    println!("Processing workspace directories...");
    fs::read_dir(base_dir)
        .map_err(|e| format!("Failed to read workspaces directory: {}", e))?
        .filter_map(|entry| entry.ok())
        .filter(|entry| entry.path().is_dir())
        .filter_map(|entry| {
            let file_name = entry.file_name();
            let entry_name = file_name.to_string_lossy().to_string();
            re.captures(&entry_name.clone()).map(|caps| (entry_name, caps["name"].to_string()))
        })
        .try_for_each(|(_entry_name, workspace_name)| {
            println!("Creating workspace: {}", workspace_name);
            let result = run_terraform(&["workspace", "new", &workspace_name]);
            if result.is_err() {
                println!("Workspace '{}' already exists, attempting to select it...", workspace_name);
                return run_terraform(&["workspace", "select", &workspace_name])
                    .map_err(|e| format!("Failed to select workspace '{}': {}", workspace_name, e));
            }
            result
        })
}

fn show_workspace_info() -> Result<(), String> {
    println!("Switching back to 'project' workspace...");
    run_terraform(&["workspace", "select", "project"])
        .map_err(|e| format!("Failed to switch to 'project' workspace: {}", e))?;
    
    println!("Current workspace:");
    run_terraform(&["workspace", "show"])
        .map_err(|e| format!("Failed to show current workspace: {}", e))?;
    
    println!("\nList of all workspaces:");
    run_terraform(&["workspace", "list"])
        .map_err(|e| format!("Failed to list workspaces: {}", e))
}

fn main() {
    let result = delete_all_workspaces()
        .and_then(|_| create_project_workspace())
        .and_then(|_| create_workspaces_from_directories())
        .and_then(|_| show_workspace_info());
        
    if let Err(e) = result {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}
