import UIKit

final class TaskDetailViewController: BaseViewController {
    var onUpdate: ((ProjectTask) -> Void)
    var onDelete: ((IndexPath) -> Void)
    
    private let server: Server
    private let settings: SettingsManager
    private let indexPath: IndexPath
    private var task: ProjectTask
    private var project: Project?
    private var employee: Employee?
    private let isOpenedFromProject: Bool
    
    private var workTimeLabel = UILabel()
    private var startDateLabel = UILabel()
    private var endDateLabel = UILabel()
    
    private var projectTitleLabel = UIFactory.createTitleLabel(text: Localized.projectLabel)
    private var workTimeTitleLabel = UIFactory.createTitleLabel(text: Localized.hoursLabel)
    private var startDateTitleLabel = UIFactory.createTitleLabel(text: Localized.startDateLabel)
    private var endDateTitleLabel = UIFactory.createTitleLabel(text: Localized.endDateLabel)
    private var employeeTitleLabel = UIFactory.createTitleLabel(text: Localized.employeeLabel)
    
    private var deleteButton = UIFactory.createDeleteButton()
    
    private var taskNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 10
        return label
    }()
    
    private var projectLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private var employeeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.borderWidth = 0.5
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 25).isActive = true
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return label
    }()
    
    private let timeCard: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.backgroundColor = .secondarySystemBackground
        stack.layer.cornerRadius = 16
        stack.layer.shadowColor = UIColor.black.cgColor
        stack.layer.shadowOpacity = 0.05
        stack.layer.shadowOffset = CGSize(width: 0, height: 2)
        stack.layer.shadowRadius = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(indexPath: IndexPath, task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, server: Server, settings: SettingsManager, onUpdate: @escaping ((ProjectTask) -> Void), onDelete: @escaping ((IndexPath) -> Void)) {
        self.indexPath = indexPath
        self.task = task
        self.project = project
        self.employee = employee
        self.isOpenedFromProject = isOpenedFromProject
        self.server = server
        self.settings = settings
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupNavigationBar(navigationTitle: Localized.taskDetails, rightButtonTitle: Localized.edit, rightButtonAction: #selector(actionChangeTask))
        setupTimeCard()
        setupStackView()
        setupButtons()
        updateLabels()
    }
    
    private func setupTimeCard() {
        let workTimeRow = UIStackView(arrangedSubviews: [workTimeTitleLabel, workTimeLabel])
        let startDateRow = UIStackView(arrangedSubviews: [startDateTitleLabel, startDateLabel])
        let endDateRow = UIStackView(arrangedSubviews: [endDateTitleLabel, endDateLabel])
        
        [workTimeRow, startDateRow, endDateRow].forEach { row in
            row.axis = .horizontal
            row.spacing = 5
            row.translatesAutoresizingMaskIntoConstraints = false
            timeCard.addArrangedSubview(row)
        }
        
        view.addSubview(timeCard)
    }
    
    private func setupStackView() {
        let projectRow = UIStackView(arrangedSubviews: [projectTitleLabel, projectLabel])
        let employeeRow = UIStackView(arrangedSubviews: [employeeTitleLabel, employeeLabel])
        
        [projectRow, employeeRow].forEach { row in
            row.axis = .horizontal
            row.spacing = 5
            row.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let taskAndStatusRow = UIStackView(arrangedSubviews: [taskNameLabel, statusLabel])
        taskAndStatusRow.axis = .vertical
        taskAndStatusRow.spacing = 5
        taskAndStatusRow.alignment = .leading
        taskAndStatusRow.translatesAutoresizingMaskIntoConstraints = false
        
        let projectAndEmployeeRow = UIStackView(arrangedSubviews: [projectRow, employeeRow])
        projectAndEmployeeRow.axis = .vertical
        projectAndEmployeeRow.spacing = 15
        projectAndEmployeeRow.translatesAutoresizingMaskIntoConstraints = false
        
        [taskAndStatusRow, projectAndEmployeeRow, timeCard].forEach { row in
            stackView.addArrangedSubview(row)
        }
        
        view.addSubview(stackView)
                
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func setupButtons() {
        deleteButton.addTarget(self, action: #selector(actionDeleteTask), for: .touchUpInside)
        
        view.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 30),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
    
    private func updateLabels() {
        taskNameLabel.text = task.taskName
        projectLabel.text = project?.projectName ?? Localized.unknownProjectLabel
        workTimeLabel.text = "\(task.workTime)"
        startDateLabel.text =  DateHelper.string(from: task.startDate)
        endDateLabel.text = DateHelper.string(from: task.endDate)
        employeeLabel.text = employee?.fullName ?? Localized.notAssignedLabel
        statusLabel.text = task.status.rawValue.localized
        
        updateStatusAppearance()
    }
    
    private func updateStatusAppearance() {
        switch task.status {
        case .notStarted:
            statusLabel.textColor = .red
            statusLabel.layer.borderColor = UIColor.red.cgColor
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        case .inProgress:
            statusLabel.textColor = .blue
            statusLabel.layer.borderColor = UIColor.blue.cgColor
            statusLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        case .completed:
            statusLabel.textColor = .green
            statusLabel.layer.borderColor = UIColor.green.cgColor
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        case .postponed:
            statusLabel.textColor = .orange
            statusLabel.layer.borderColor = UIColor.orange.cgColor
            statusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        }
    }
    
    private func reloadTaskDetails() async {
        do {
            async let projects = server.fetchProjects()
            async let employees = server.fetchEmployees()
            
            let allProjects = try await projects
            let allEmployees = try await employees
            
            await MainActor.run {
                project = allProjects.first { $0.id == task.projectID }
                employee = allEmployees.first { $0.id == task.employeeID }
                updateLabels()
                stopLoading()
            }
        } catch {
            await MainActor.run {
                stopLoading()
                showAlert(Localized.loadFailed)
            }
        }
    }
    
    @objc private func actionDeleteTask() {
        onDelete(indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionChangeTask() {
        let onUpdate = {[weak self] task in
            self?.task = task
            self?.onUpdate(task)
            self?.startLoading()
            Task {
                await self?.reloadTaskDetails()
            }
        }
        
        if let project, isOpenedFromProject == true {
            let editModuleViewController = EditTaskBuilder.build(
                task: task,
                project: project,
                server: server,
                settings: settings,
                action: .update(onUpdate)
            )
            navigationController?.pushViewController(editModuleViewController, animated: true)
        } else {
            let editModuleViewController = EditTaskBuilder.build(
                task: task,
                server: server,
                settings: settings,
                action: .update(onUpdate)
            )
            navigationController?.pushViewController(editModuleViewController, animated: true)
        }
    }
}
