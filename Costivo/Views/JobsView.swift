import SwiftUI
import SwiftData

struct JobsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Job.createdDate, order: .reverse) private var jobs: [Job]
    @State private var showingAddJob = false
    @State private var selectedJob: Job?
    @State private var searchText = ""
    
    private var filteredJobs: [Job] {
        if searchText.isEmpty {
            return jobs
        }
        return jobs.filter { $0.clientName.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredJobs) { job in
                    JobRow(job: job)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedJob = job
                        }
                }
                .onDelete(perform: deleteJobs)
            }
            .navigationTitle(L(.jobs))
            .if(jobs.count > 5) { view in
                view.searchable(text: $searchText, prompt: L(.searchByClientName))
            }
            .toolbar {
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
                        systemImage: "doc.text",
                        description: Text(L(.createFirstJob))
                    )
                }
            }
        }
    }
    
    private func deleteJobs(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(jobs[index])
        }
    }
}

struct JobRow: View {
    let job: Job
    @Query private var settings: [AppSettings]
    
    private var currency: String {
        settings.first?.preferredCurrency ?? "MKD"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(job.clientName)
                    .font(.headline)
                Text(job.createdDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(currency)\(job.totalCost, specifier: "%.2f")")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
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
