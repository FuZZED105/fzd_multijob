var job = 'unemployed';
var grade = 0;

async function addJob(info) {
    var status = 'SELECT';
    var removeButton = '';
    var removeable = 'hidden';

    if (info.name == job && info.grade == grade) {
        status = 'SELECTED';
    }

    if (info.removeable) {
        removeable = '';
        removeButton = `<div class="job-remove" data-job="${info.name}" data-grade="${info.grade}">REMOVE</div>`;
    }

    var jobPanel = `
        <div class="job-card">
            <div class="job-name">${info.label}</div>
            <div class="job-grade">${info.gradeLabel}</div>
            <div class="job-status" data-job="${info.name}" data-grade="${info.grade}">${status}</div>
            ${removeButton}
        </div>
    `

    $("#jobs").append(jobPanel);
}

window.addEventListener("load", () => {
    $.post('https://fzd_multijob/getJobs', JSON.stringify({}), function(data) {
        job = data.job.job;
        grade = data.job.grade;

        const jobs = JSON.parse(data.jobs);

        for (i = 0; i < jobs.length; i++) {
            addJob(jobs[i]);
        }
    });

    $("body").on("click", ".job-status", function(e) {
        e.preventDefault();

        $(document).find(".job-status").text('SELECT');
        $(this).text('SELECTED');

        $.post('https://fzd_multijob/changejob', JSON.stringify({
            job: this.dataset.job,
            grade: this.dataset.grade
        }));
    });

    $("body").on("click", ".job-remove", function(e) {
        e.preventDefault();

        $(this).parent().fadeOut();

        $.post('https://fzd_multijob/removejob', JSON.stringify({
            job: this.dataset.job,
            grade: this.dataset.grade
        }));
    });
});