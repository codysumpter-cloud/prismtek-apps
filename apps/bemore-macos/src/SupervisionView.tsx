import React, { useState, useEffect } from 'react';
import { iBuddyClient } from './runtimeClient';

const client = new iBuddyClient();

export const SupervisionView: React.FC = () => {
  const [goal, setGoal] = useState('');
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [events, setEvents] = useState<any[]>([]);
  const [artifactContent, setArtifactContent] = useState<string | null>(null);
  const [isLaunching, setIsLaunching] = useState(false);

  const handleLaunch = async () => {
    setIsLaunching(true);
    try {
      const sid = await client.launchTask(goal);
      setSessionId(sid);
      setEvents([]);
      
      client.streamEvents(sid, (event) => {
        setEvents((prev) => [...prev, event]);
      });
    } catch (e) {
      alert('Error launching task: ' + e);
    } finally {
      setIsLaunching(false);
    }
  };

  const handleApproval = async (actionId: string, decision: 'approve' | 'reject') => {
    if (!sessionId) return;
    try {
      await client.submitApproval(sessionId, actionId, decision);
    } catch (e) {
      alert('Approval failed: ' + e);
    }
  };

  const viewArtifact = async (artifactId: string) => {
    if (!sessionId) return;
    try {
      const content = await client.getArtifact(artifactId);
      setArtifactContent(content);
    } catch (e) {
      alert('Fetch failed: ' + e);
    }
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'sans-serif', maxWidth: '800px', margin: '0 auto' }}>
      <h1>iBeMore Workbench - Supervision Slice</h1>
      
      <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
        <input 
          style={{ flex: 1, padding: '8px' }} 
          value={goal} 
          onChange={(e) => setGoal(e.target.value)} 
          placeholder="Enter goal (e.g. Create hello.txt)"
        />
        <button onClick={handleLaunch} disabled={isLaunching}>
          {isLaunching ? 'Launching...' : 'Launch Buddy'}
        </button>
      </div>

      <div style={{ display: 'flex', gap: '20px' }}>
        <div style={{ flex: 1, border: '1px solid #ccc', padding: '10px', height: '500px', overflowY: 'auto', borderRadius: '8px' }}>
          <h3>Event Stream</h3>
          {events.map((event, idx) => (
            <div key={idx} style={{ marginBottom: '10px', padding: '8px', borderBottom: '1px solid #eee', fontSize: '14px' }}>
              <strong>{event.type}</strong>: {event.message || event.tool_name || ''}
              
              {event.type === 'tool_request' && (
                <div style={{ marginTop: '5px' }}>
                  <button onClick={() => handleApproval(event.action_id, 'approve')} style={{ marginRight: '5px', color: 'green' }}>Approve</button>
                  <button onClick={() => handleApproval(event.action_id, 'reject')} style={{ color: 'red' }}>Reject</button>
                </div>
              )}

              {event.type === 'artifact_created' && (
                <button onClick={() => viewArtifact(event.artifact_id)} style={{ marginLeft: '10px' }}>View</button>
              )}
            </div>
          ))}
        </div>

        <div style={{ flex: 1, border: '1px solid #ccc', padding: '10px', height: '500px', overflowY: 'auto', borderRadius: '8px', backgroundColor: '#f9f9f9' }}>
          <h3>Artifact Viewer</h3>
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: '12px' }}>
            {artifactContent || 'No artifact selected'}
          </pre>
        </div>
      </div>
    </div>
  );
};
