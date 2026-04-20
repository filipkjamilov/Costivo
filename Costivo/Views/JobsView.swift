import SwiftUI
import SwiftData

struct JobsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Job.createdDate, order: .reverse) private var jobs: [Job]
    @Query private var settings: [AppSettings]
    @State private var showingAddJob = false
    @State private var selectedJob: Job?
    @State private var searchText = ""
    @State private var selectedFilter: JobFilter = .all

    private var filteredJobs: [Job] {
        let bySearch = searchText.isEmpty ? jobs : jobs.filter {
            $0.clientName.localizedCaseInsensitiveContains(searchText)
        }
        switch selectedFilter {
        case .all:
            return bySearch.filter { $0.status != .archived }
        case .upcoming:
            return bySearch.filter { $0.dueDate != nil && !$0.isOverdue && $0.status != .completed && $0.status != .archived }
        case .overdue:
            return bySearch.filter { $0.isOverdue && $0.status != .archived }
        case .completed:
            return bySearch.filter { $0.status == .completed }
        case .archived:
            return bySearch.filter { $0.status == .archived }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredJobs) { job in
                    JobRow(job: job)
                        .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedJob = job
                        }
                        .swipeActions(edge: .leading) {
                            if job.status == .archived {
                                Button {
                                    job.status = .completed
                                } label: {
                                    Label(L(.markCompleted), systemImage: "arrow.uturn.backward")
                                }
                                .tint(.blue)
                            } else if job.status != .completed {
                                Button {
                                    job.status = .completed
                                } label: {
                                    Label(L(.markCompleted), systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            } else {
                                Button {
                                    job.status = job.dueDate != nil ? .scheduled : .draft
                                } label: {
                                    Label(L(.markScheduled), systemImage: "arrow.uturn.backward")
                                }
                                .tint(.blue)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if job.status == .completed {
                                Button {
                                    withAnimation { job.status = .archived }
                                } label: {
                                    Label(L(.archiveJob), systemImage: "archivebox")
                                }
                                .tint(.orange)
                            }
                        }
                }
                .onDelete(perform: deleteJobs)
            }
            .appBackground()
            .navigationTitle(L(.jobs))
            .if(jobs.count > 5) { view in
                view.searchable(text: $searchText, prompt: L(.searchByClientName))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(JobFilter.allCases, id: \.self) { filter in
                            Button {
                                withAnimation { selectedFilter = filter }
                            } label: {
                                if selectedFilter == filter {
                                    Label(filter.label, systemImage: "checkmark")
                                } else {
                                    Text(filter.label)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: selectedFilter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddJob = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddJob) {
                AddJobView()
            }
            .sheet(item: $selectedJob) { job in
                JobDetailView(job: job)
            }
            .overlay {
                if jobs.isEmpty {
                    ContentUnavailableView(
                        L(.noJobs),
                        systemImage: settings.handymanType.jobsIcon,
                        description: Text(L(.createFirstJob))
                    )
                }
            }
        }
    }
    
    private func deleteJobs(at offsets: IndexSet) {
        let jobsToDelete = offsets.map { filteredJobs[$0] }
        for job in jobsToDelete {
            modelContext.delete(job)
        }
    }
}

struct JobRow: View {
    let job: Job
    @Query private var settings: [AppSettings]

    private var currency: String {
        settings.currency
    }

    var body: some View {
        HStack {
            if job.status == .completed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(job.clientName)
                    .font(.headline)
                    .foregroundStyle(job.status == .completed ? .secondary : .primary)

                HStack(spacing: 6) {
                    Text(job.createdDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let dueDate = job.dueDate {
                        Text("·")
                            .foregroundStyle(.secondary)

                        if job.isOverdue {
                            Label(L(.overdue), systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.red)
                        } else {
                            Label {
                                Text(dueDate, format: .dateTime.month(.abbreviated).day())
                                    .lineLimit(1)
                                    .fixedSize()
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.caption)
                            .foregroundStyle(job.status == .completed ? Color.secondary : Color.orange)
                        }
                    }
                }
            }

            Spacer()

            Text("\(currency)\(job.totalCost, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(job.status == .completed ? .secondary : .primary)
        }
        .padding(.vertical, 4)
    }
}

enum JobFilter: CaseIterable {
    case all, upcoming, overdue, completed, archived

    var label: String {
        switch self {
        case .all:       return L(.filterAll)
        case .upcoming:  return L(.filterUpcoming)
        case .overdue:   return L(.filterOverdue)
        case .completed: return L(.filterCompleted)
        case .archived:  return L(.filterArchived)
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    JobsView()
        .modelContainer(for: [Job.self, JobMaterial.self, JobLabor.self, AppSettings.self])
}
